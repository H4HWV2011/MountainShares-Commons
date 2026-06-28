#!/usr/bin/env python3
"""
render_tech_pages.py — renders 03-technology/data-stores.md and port-map.md
from 04-evidence/facts.json. These pages are GENERATED; do not hand-edit them.

Run after collect_evidence.py. Reads only committed evidence; writes only the
two generated pages.
"""
import json, os, sys

def find_repo_root():
    d = os.getcwd()
    while True:
        if os.path.isdir(os.path.join(d, "04-evidence")) and os.path.isdir(os.path.join(d, "03-technology")):
            return d
        nd = os.path.dirname(d)
        if nd == d:
            sys.exit("ERROR: run from inside the MountainShares-Commons repo.")
        d = nd

ROOT = find_repo_root()
EVID = os.path.join(ROOT, "04-evidence")
TECH = os.path.join(ROOT, "03-technology")
FACTS = os.path.join(EVID, "facts.json")
if not os.path.isfile(FACTS):
    sys.exit("ERROR: %s not found. Run collect_evidence.py first." % FACTS)
F = json.load(open(FACTS))

def g(d, *keys, default="unavailable"):
    for k in keys:
        if not isinstance(d, dict):
            return default
        d = d.get(k, default)
        if d is None:
            return default
    return d

def commas(n):
    try:
        return "{:,}".format(int(n))
    except Exception:
        return str(n)

GEN_NOTE = (
    "> **GENERATED FILE — do not hand-edit.** Rendered from `../04-evidence/facts.json` "
    "(snapshot `%s`). To update, re-run the evidence pipeline:\n"
    "> `PGPASSWORD=… ./04-evidence/scripts/update_evidence.sh` (add `--full` to recount the backup corpus).\n"
    % g(F, "snapshot_utc")
)

# ----------------------------- data-stores.md -------------------------------
def render_data_stores():
    ch = F.get("chroma", {})
    live = ch.get("live", {}); bak = ch.get("backup", {})
    L = []
    L.append("# Data Stores")
    L.append("")
    L.append(GEN_NOTE)
    L.append("")
    L.append("Ms. Allis pairs a semantic store (H_App) with a spatial store (H_geo): "
             "**H_App \u2297 H_geo = ChromaDB \u2297 PostGIS**. This page reports the *live* state "
             "of both, verified read-only on the snapshot date.")
    L.append("")
    # Chroma
    L.append("## H_App \u2014 ChromaDB (semantic / vector)")
    L.append("")
    L.append("| Store | Collections | Vectors | Size | Notes |")
    L.append("|---|---|---|---|---|")
    L.append("| **Live (mounted)** | %s | %s | %s | path `%s` |" % (
        g(live, "collections"), commas(g(live, "vectors")),
        "\u2014", g(live, "store_path")))
    bsize = bak.get("size_bytes")
    bsize_h = ("%.0f GB" % (bsize / 1e9)) if isinstance(bsize, int) else "unavailable"
    L.append("| **Canonical backup** | %s | %s | %s | verified %s |" % (
        g(bak, "collections"), commas(g(bak, "vectors")),
        bsize_h, g(bak, "vectors_verified_at")))
    L.append("")
    mig = bak.get("migrations") or {}
    if mig:
        L.append("Backup on-disk schema: " + ", ".join("`%s v%s`" % (k, v) for k, v in sorted(mig.items())) + ".")
        L.append("")
    # live-vs-backup honesty line
    lv, bv = live.get("vectors"), bak.get("vectors")
    if isinstance(lv, int) and isinstance(bv, int) and bv > lv * 10:
        L.append("> **Live vs. canonical:** the mounted store holds **%s** vectors while the "
                 "canonical backup holds **%s**. The live store is a reduced/shell store; the "
                 "full corpus lives in the backup and is restored/repointed separately." % (commas(lv), commas(bv)))
        L.append("")
    # Postgres
    L.append("## H_geo \u2014 PostgreSQL / PostGIS (spatial / relational)")
    L.append("")
    L.append("| Endpoint | Status | Databases (size) | Role |")
    L.append("|---|---|---|---|")
    for inst in F.get("postgres", {}).get("instances", []):
        dbs = inst.get("databases") or []
        dbtxt = "; ".join("%s (%s)" % (d["name"], d["size"]) for d in dbs) or "\u2014"
        role = "**spatial body**" if inst.get("spatial_body") else ""
        L.append("| `%s` | %s | %s | %s |" % (
            inst.get("endpoint"), inst.get("status"), dbtxt, role))
    L.append("")
    # spatial detail
    for inst in F.get("postgres", {}).get("instances", []):
        if inst.get("spatial_body"):
            det = []
            if inst.get("schemas") is not None:
                det.append("%s schemas / %s tables" % (inst.get("schemas"), inst.get("tables")))
            sr = inst.get("sample_rows") or {}
            for k, v in sr.items():
                det.append("`%s` = %s rows" % (k, commas(v)))
            if det:
                L.append("Spatial body (`%s`, `msjarvisgis`): " % inst.get("endpoint") + "; ".join(det) +
                         ". Row counts are live `count(*)` values; planner statistics may read 0 if tables "
                         "were bulk-loaded without `ANALYZE`.")
                L.append("")
    L.append("---")
    L.append("*Source: `../04-evidence/facts.json`. Regenerate; do not edit by hand.*")
    return "\n".join(L) + "\n"

# ----------------------------- port-map.md ----------------------------------
def render_port_map():
    c = F.get("containers", {})
    L = []
    L.append("# Port Map")
    L.append("")
    L.append(GEN_NOTE)
    L.append("")
    L.append("Complete published port surface of the live container fleet, verified read-only.")
    L.append("")
    L.append("| Metric | Value |")
    L.append("|---|---|")
    L.append("| Running containers | %s |" % g(c, "running"))
    L.append("| Published bindings | %s |" % g(c, "published_bindings"))
    L.append("| Internal-only ports | %s |" % g(c, "internal_only"))
    L.append("| Distinct host ports | %s |" % g(c, "distinct_host_ports"))
    L.append("| Host-port collisions | %s |" % g(c, "collisions"))
    L.append("| Non-loopback bindings | %s |" % len(c.get("nonloopback", [])))
    L.append("| Firewall (ufw) | %s |" % g(F, "firewall", "ufw"))
    L.append("| Public URL / (HTTP) | %s |" % g(F, "public", "root_http"))
    L.append("")
    nl = c.get("nonloopback", [])
    L.append("## Non-loopback bindings (network-reachable surface)")
    L.append("")
    if nl:
        L.append("| Container | Binding | Proto |")
        L.append("|---|---|---|")
        for r in nl:
            L.append("| %s | `%s` | %s |" % (r.get("container"), r.get("binding"), r.get("proto")))
        if str(g(F, "firewall", "ufw")).lower().startswith("inactive"):
            L.append("")
            L.append("> **ufw is inactive** \u2014 the bindings above are reachable on the local "
                     "network. Public internet exposure is mediated by the Cloudflare tunnel; "
                     "host database/service ports are not tunneled (LAN-scoped).")
    else:
        L.append("All published bindings are loopback-only (127.0.0.1).")
    L.append("")
    # full canonical map embedded from captured artifact
    mp = os.path.join(EVID, "snapshots", "latest", "port_map_canonical.txt")
    if os.path.isfile(mp):
        L.append("## Full canonical port map")
        L.append("")
        L.append("<details><summary>All published ports (container_port \u2192 host_ip:host_port)</summary>")
        L.append("")
        L.append("```")
        L.append(open(mp).read().rstrip())
        L.append("```")
        L.append("</details>")
        L.append("")
    L.append("---")
    L.append("*Source: `../04-evidence/facts.json` and `../04-evidence/snapshots/latest/`. "
             "Regenerate; do not edit by hand.*")
    return "\n".join(L) + "\n"

open(os.path.join(TECH, "data-stores.md"), "w").write(render_data_stores())
open(os.path.join(TECH, "port-map.md"), "w").write(render_port_map())
print("Rendered:")
print("  ", os.path.join(TECH, "data-stores.md"))
print("  ", os.path.join(TECH, "port-map.md"))
