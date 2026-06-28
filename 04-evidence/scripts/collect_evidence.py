#!/usr/bin/env python3
"""
collect_evidence.py  — READ-ONLY live-system evidence collector.

Probes containers, ports, ollama, ChromaDB (live + canonical backup), PostgreSQL
(all instances), firewall, and the public endpoint, and writes a single
machine-readable source of truth: 04-evidence/facts.json. Also captures the port
tables into 04-evidence/snapshots/latest/ for the renderer.

Nothing here mutates the system. Failures are recorded as "unavailable (reason)",
never invented.

Auth: host PostgreSQL queries use $PGPASSWORD if set (run e.g.
  PGPASSWORD=postgres python3 collect_evidence.py --full).
No password is stored in this file.

Flags:
  --full   Recount the 96 GB backup's vectors (slow, minutes). Without it, the
           prior verified backup vector count in facts.json is preserved as-is.
"""
import json, os, subprocess, sys, time, urllib.request

FULL = "--full" in sys.argv

def run(cmd, timeout=60, shell=False):
    try:
        r = subprocess.run(cmd, shell=shell, capture_output=True, text=True, timeout=timeout)
        return r.returncode, (r.stdout or ""), (r.stderr or "")
    except Exception as e:
        return 1, "", str(e)

def find_repo_root():
    d = os.getcwd()
    while True:
        if os.path.isdir(os.path.join(d, "04-evidence")) and os.path.isdir(os.path.join(d, "03-technology")):
            return d
        nd = os.path.dirname(d)
        if nd == d:
            sys.exit("ERROR: run from inside the MountainShares-Commons repo "
                     "(could not find 04-evidence/ and 03-technology/).")
        d = nd

ROOT = find_repo_root()
EVID = os.path.join(ROOT, "04-evidence")
LATEST = os.path.join(EVID, "snapshots", "latest")
os.makedirs(LATEST, exist_ok=True)
FACTS_PATH = os.path.join(EVID, "facts.json")

prior = {}
if os.path.isfile(FACTS_PATH):
    try:
        prior = json.load(open(FACTS_PATH))
    except Exception:
        prior = {}

facts = {
    "snapshot_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "host": (run(["hostname"])[1].strip() or "unknown"),
    "generator": "collect_evidence.py",
}

# ---- containers + ports ----------------------------------------------------
def collect_containers():
    out = {"running": None, "published_bindings": None, "internal_only": None,
           "distinct_host_ports": None, "collisions": None, "nonloopback": [],
           "status": "ok"}
    rc, ids, _ = run(["bash", "-lc", "docker ps -aq"])
    if rc != 0:
        out["status"] = "unavailable (docker not reachable)"; return out
    rc, runq, _ = run(["bash", "-lc", "docker ps -q | wc -l"])
    out["running"] = int(runq.strip() or 0)
    rc, js, err = run(["bash", "-lc", "docker inspect $(docker ps -aq)"], timeout=120)
    if rc != 0 or not js.strip():
        out["status"] = "unavailable (inspect failed)"; return out
    try:
        data = json.loads(js)
    except Exception as e:
        out["status"] = "unavailable (inspect parse: %s)" % e; return out
    pub, internal = [], []
    for c in data:
        name = c.get("Name", "").lstrip("/")
        ports = ((c.get("NetworkSettings") or {}).get("Ports")) or {}
        exposed = ((c.get("Config") or {}).get("ExposedPorts")) or {}
        for cp, binds in ports.items():
            cport, proto = (cp.split("/") + ["tcp"])[:2]
            if binds:
                for b in binds:
                    pub.append((name, b.get("HostIp", ""), b.get("HostPort", ""), cport, proto))
            else:
                internal.append((name, cport, proto))
        for cp in exposed:
            if cp not in ports:
                cport, proto = (cp.split("/") + ["tcp"])[:2]
                internal.append((name, cport, proto))
    nl = [r for r in pub if r[1] not in ("127.0.0.1", "")]
    seen = {}
    for r in pub:
        seen.setdefault((r[1], r[2], r[4]), set()).add(r[0])
    coll = [k for k, v in seen.items() if len(v) > 1]
    out["published_bindings"] = len(pub)
    out["internal_only"] = len(internal)
    out["distinct_host_ports"] = len(set(r[2] for r in pub if r[2].isdigit()))
    out["collisions"] = len(coll)
    seen_nl = set(); nl_entries = []
    for r in nl:
        key = (r[0], r[2], r[4])  # container, host_port, proto  -> collapse v4/v6
        if key in seen_nl:
            continue
        seen_nl.add(key)
        ip = r[1] if r[1] not in ("::", "[::]") else "0.0.0.0"
        nl_entries.append({"container": r[0], "binding": "%s:%s" % (ip, r[2]),
                           "container_port": r[3], "proto": r[4]})
    out["nonloopback"] = nl_entries
    # capture port tables for the renderer
    pub_sorted = sorted(pub, key=lambda r: int(r[2]) if r[2].isdigit() else 0)
    with open(os.path.join(LATEST, "ports_published.tsv"), "w") as f:
        f.write("container\thost_ip\thost_port\tcontainer_port\tproto\n")
        for r in pub_sorted:
            f.write("\t".join(r) + "\n")
    with open(os.path.join(LATEST, "port_map_canonical.txt"), "w") as f:
        for r in pub_sorted:
            f.write("%-16s -> %s:%-7s  %s\n" % (r[3] + "/" + r[4], r[1], r[2], r[0]))
    return out

facts["containers"] = collect_containers()

# ---- ollama ----------------------------------------------------------------
def collect_ollama():
    rc, out, _ = run(["bash", "-lc", "docker exec jarvis-ollama ollama list"])
    if rc != 0:
        return {"models": None, "status": "unavailable (jarvis-ollama not reachable)"}
    lines = [l for l in out.splitlines() if l.strip()]
    n = max(0, len(lines) - 1)  # drop header
    return {"models": n, "status": "ok"}

facts["ollama"] = collect_ollama()

# ---- chroma (live via API + backup via sqlite) -----------------------------
def chroma_live():
    res = {"collections": None, "vectors": None, "store_path": None, "status": "ok"}
    base = "http://127.0.0.1:8002/api/v2/tenants/default_tenant/databases/default_database/collections"
    try:
        cols = json.load(urllib.request.urlopen(base, timeout=15))
    except Exception as e:
        res["status"] = "unavailable (%s)" % e; return res
    total = 0
    for c in cols:
        try:
            n = json.load(urllib.request.urlopen(base + "/" + c["id"] + "/count", timeout=15))
            if isinstance(n, int):
                total += n
        except Exception:
            pass
    res["collections"] = len(cols)
    res["vectors"] = total
    rc, mnt, _ = run(["bash", "-lc",
        "docker inspect jarvis-chroma --format '{{range .Mounts}}{{.Source}}|{{.Destination}}\\n{{end}}'"])
    for line in mnt.splitlines():
        if "|/data" in line or line.endswith("|/data"):
            src = line.split("|")[0]
            rc2, real, _ = run(["bash", "-lc", "readlink -f '%s'" % src])
            res["store_path"] = (real.strip() or src)
            break
    return res

def sqlite_ro(path, sql, timeout=900):
    rc, out, err = run(["bash", "-lc",
        "sqlite3 \"file:%s?mode=ro&immutable=1\" \"%s\"" % (path, sql)], timeout=timeout)
    return out.strip() if rc == 0 else None

def chroma_backup():
    res = {"path": None, "size_bytes": None, "collections": None, "vectors": None,
           "vectors_verified_at": None, "migrations": {}, "status": "ok"}
    rc, out, _ = run(["bash", "-lc",
        "find /mnt/nvme1/msjarvis-data /mnt/nvme1 -maxdepth 6 -name chroma.sqlite3 -type f "
        "-printf '%s\\t%p\\n' 2>/dev/null | sort -rn | head -1"])
    if not out.strip():
        res["status"] = "unavailable (no backup chroma.sqlite3 found)"; return res
    size, path = out.strip().split("\t", 1)
    res["path"] = path; res["size_bytes"] = int(size)
    cc = sqlite_ro(path, "SELECT count(*) FROM collections;", timeout=60)
    res["collections"] = int(cc) if cc and cc.isdigit() else None
    mg = sqlite_ro(path, "SELECT dir||'='||MAX(version) FROM migrations GROUP BY dir;", timeout=60)
    if mg:
        for line in mg.splitlines():
            if "=" in line:
                k, v = line.split("=", 1)
                res["migrations"][k] = int(v) if v.isdigit() else v
    if FULL:
        v = sqlite_ro(path, "SELECT count(*) FROM embeddings;", timeout=1800)
        if v and v.isdigit():
            res["vectors"] = int(v)
            res["vectors_verified_at"] = facts["snapshot_utc"]
    else:
        pb = (prior.get("chroma", {}) or {}).get("backup", {}) or {}
        # preserve prior verified count only if it's the same backup file
        if pb.get("path") == path and pb.get("vectors"):
            res["vectors"] = pb["vectors"]
            res["vectors_verified_at"] = pb.get("vectors_verified_at")
            res["status"] = "ok (vectors preserved from prior --full run; rerun with --full to recount)"
        else:
            res["status"] = "vectors not counted (run with --full)"
    return res

facts["chroma"] = {"live": chroma_live(), "backup": chroma_backup()}

# ---- postgres --------------------------------------------------------------
def pg_host(port):
    conn = "host=127.0.0.1 port=%d user=postgres connect_timeout=5" % port
    rc, out, err = run(["bash", "-lc",
        "psql \"%s\" -At -c \"select datname, pg_size_pretty(pg_database_size(datname)) "
        "from pg_database where datname not like 'template%%' and datname<>'postgres' "
        "order by pg_database_size(datname) desc;\"" % conn], timeout=30)
    if rc != 0:
        return None, ("unavailable (%s)" % (err.strip().splitlines()[-1] if err.strip() else "auth/connect failed"))
    dbs = []
    for line in out.splitlines():
        if "|" in line:
            n, s = line.split("|", 1); dbs.append({"name": n, "size": s})
    return dbs, "ok"

def pg_query(port, db, sql):
    conn = "host=127.0.0.1 port=%d user=postgres dbname=%s connect_timeout=5" % (port, db)
    rc, out, _ = run(["bash", "-lc", "psql \"%s\" -At -c \"%s\"" % (conn, sql)], timeout=60)
    return out.strip() if rc == 0 else None

def collect_postgres():
    instances = []
    for port in (5432, 5433):
        dbs, st = pg_host(port)
        inst = {"endpoint": "host:%d" % port, "status": st, "databases": dbs or []}
        if dbs:
            big = max(dbs, key=lambda d: 0)  # order already desc; first is largest
            inst["largest_db"] = dbs[0]["name"]
            if any(d["name"] == "msjarvisgis" for d in dbs):
                # spatial detail only where msjarvisgis is the largest db on this endpoint
                if dbs[0]["name"] == "msjarvisgis":
                    inst["spatial_body"] = True
                    st2 = pg_query(port, "msjarvisgis",
                        "select count(distinct table_schema)||'|'||count(*) from information_schema.tables "
                        "where table_schema not in ('pg_catalog','information_schema');")
                    if st2 and "|" in st2:
                        sc, tb = st2.split("|", 1)
                        inst["schemas"] = int(sc) if sc.isdigit() else None
                        inst["tables"] = int(tb) if tb.isdigit() else None
                    sample = {}
                    for label, q in (("wv_tax_parcels_2025", "select count(*) from raw.wv_tax_parcels_2025"),
                                     ("buildings", "select count(*) from public.buildings")):
                        v = pg_query(port, "msjarvisgis", q)
                        if v and v.isdigit():
                            sample[label] = int(v)
                    if sample:
                        inst["sample_rows"] = sample
        instances.append(inst)
    # containerized postgis
    rc, out, _ = run(["bash", "-lc",
        "docker exec jarvis-local-resources-db psql -U postgres -At -c "
        "\"select datname, pg_size_pretty(pg_database_size(datname)) from pg_database "
        "where datname not like 'template%' and datname<>'postgres' order by 1;\""])
    cinst = {"endpoint": "container:jarvis-local-resources-db (host 5435)",
             "status": "ok" if rc == 0 else "unavailable", "databases": []}
    if rc == 0:
        for line in out.splitlines():
            if "|" in line:
                n, s = line.split("|", 1); cinst["databases"].append({"name": n, "size": s})
    instances.append(cinst)
    return {"instances": instances}

facts["postgres"] = collect_postgres()

# ---- firewall + public -----------------------------------------------------
def collect_firewall():
    rc, out, _ = run(["bash", "-lc", "ufw status 2>/dev/null | head -1"])
    if rc != 0 or not out.strip():
        rc, out, _ = run(["bash", "-lc", "sudo -n ufw status 2>/dev/null | head -1"])
    val = out.strip().replace("Status:", "").strip() if rc == 0 and out.strip() else "unknown (run via sudo to capture)"
    return {"ufw": val}

facts["firewall"] = collect_firewall()

def collect_public():
    rc, out, _ = run(["bash", "-lc",
        "curl -s -o /dev/null -w '%{http_code}' --max-time 10 https://egeria.mountainshares.us/"])
    return {"root_http": out.strip() or "unavailable"}

facts["public"] = collect_public()

# ---- write -----------------------------------------------------------------
with open(FACTS_PATH, "w") as f:
    json.dump(facts, f, indent=2)
    f.write("\n")

print("Wrote %s" % FACTS_PATH)
print("  containers.running     :", facts["containers"].get("running"))
print("  ports nonloopback      :", len(facts["containers"].get("nonloopback", [])))
print("  ollama.models          :", facts["ollama"].get("models"))
print("  chroma.live.vectors    :", facts["chroma"]["live"].get("vectors"))
print("  chroma.backup.vectors  :", facts["chroma"]["backup"].get("vectors"),
      "(" + str(facts["chroma"]["backup"].get("status")) + ")")
print("  postgres.instances     :", len(facts["postgres"]["instances"]))
print("  firewall.ufw           :", facts["firewall"].get("ufw"))
print("Port artifacts captured in", LATEST)
