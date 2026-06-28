#!/usr/bin/env bash
# msjarvis_port_audit.sh  (v2)
# Complete port audit -> dated artifact folder. Non-fatal probes.
# v2 fixes: docker inspect written to file (no stdin/heredoc conflict);
#           artifacts land in invoking user's home even under sudo;
#           comm reconcile sorted consistently (LC_ALL=C);
#           adds full-range nmap localhost scan + a union of ALL listening ports.
# Run with sudo for process attribution + firewall + nmap completeness:
#   sudo ./msjarvis_port_audit.sh
export LC_ALL=C
TS="$(date +%Y%m%d_%H%M%S)"
REAL_USER="${SUDO_USER:-$(id -un)}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"; [ -z "$REAL_HOME" ] && REAL_HOME="$HOME"
OUT="$REAL_HOME/audit-snapshots/portaudit_${TS}"
mkdir -p "$OUT" || { echo "cannot create $OUT"; exit 1; }
echo "Port-audit dir: $OUT"
have() { command -v "$1" >/dev/null 2>&1; }
log()  { echo "[$(date +%H:%M:%S)] $*"; }

# 00 — meta
{
  echo "snapshot_utc: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "host: $(hostname)"
  echo "running_as: $(id -un) (uid $(id -u))  invoking_user: $REAL_USER"
  echo "docker: $(docker --version 2>/dev/null)"
  echo "nmap: $(nmap --version 2>/dev/null | head -1 || echo 'not installed')"
} > "$OUT/00_meta.txt" 2>&1

# 01 — inspect all containers (to file) -> structured port tables
docker inspect $(docker ps -aq) > "$OUT/_inspect.json" 2>/dev/null
python3 - "$OUT" "$OUT/_inspect.json" <<'PY'
import json,sys
out,src=sys.argv[1],sys.argv[2]
try: data=json.load(open(src))
except Exception as e:
    open(out+"/01_inspect_error.txt","w").write("inspect parse error: %s\n"%e); sys.exit(0)
pub=[]; internal=[]
for c in data:
    name=c.get("Name","").lstrip("/")
    state=(c.get("State") or {}).get("Status","")
    ports=((c.get("NetworkSettings") or {}).get("Ports")) or {}
    exposed=((c.get("Config") or {}).get("ExposedPorts")) or {}
    for cp,binds in ports.items():
        cport,proto=(cp.split("/")+["tcp"])[:2]
        if binds:
            for b in binds: pub.append((name,b.get("HostIp",""),b.get("HostPort",""),cport,proto,state))
        else: internal.append((name,cport,proto,state))
    for cp in exposed:
        if cp not in ports:
            cport,proto=(cp.split("/")+["tcp"])[:2]; internal.append((name,cport,proto,state))
def w(fn,rows,hdr):
    with open(out+"/"+fn,"w") as f:
        f.write("\t".join(hdr)+"\n")
        for r in rows: f.write("\t".join(str(x) for x in r)+"\n")
pub.sort(key=lambda r:(int(r[2]) if r[2].isdigit() else 0))
w("01_ports_published.tsv",pub,["container","host_ip","host_port","container_port","proto","state"])
internal.sort(key=lambda r:(r[0],r[1]))
w("01_ports_internal_only.tsv",internal,["container","container_port","proto","state"])
nl=[r for r in pub if r[1] not in ("127.0.0.1","")]
w("02_ports_nonloopback.tsv",nl,["container","host_ip","host_port","container_port","proto","state"])
from collections import defaultdict
seen=defaultdict(list)
for r in pub: seen[(r[1],r[2],r[4])].append(r[0])
coll=[(k[0],k[1],k[2],",".join(sorted(set(v)))) for k,v in seen.items() if len(set(v))>1]
w("03_ports_collisions.tsv",coll,["host_ip","host_port","proto","containers"])
with open(out+"/01_counts.txt","w") as f:
    f.write("containers_inspected: %d\n"%len(data))
    f.write("published_bindings: %d\n"%len(pub))
    f.write("internal_only_ports: %d\n"%len(internal))
    f.write("nonloopback_bindings: %d\n"%len(nl))
    f.write("host_port_collisions: %d\n"%len(coll))
    f.write("distinct_host_ports: %d\n"%len(set(r[2] for r in pub if r[2].isdigit())))
print("published=%d internal=%d nonloopback=%d collisions=%d"%(len(pub),len(internal),len(nl),len(coll)))
PY
log "01 container port tables done"

# 04/05 — host listeners
if have ss; then ss -H -tulpn 2>/dev/null > "$OUT/04_host_listeners.txt"
elif have netstat; then netstat -tulpn 2>/dev/null > "$OUT/04_host_listeners.txt"
else echo "neither ss nor netstat" > "$OUT/04_host_listeners.txt"; fi
grep -vE '127\.0\.0\.1:|\[::1\]:' "$OUT/04_host_listeners.txt" 2>/dev/null > "$OUT/05_host_listeners_external.txt"
[ -s "$OUT/05_host_listeners_external.txt" ] || echo "none (all loopback)" > "$OUT/05_host_listeners_external.txt"
log "04/05 host listeners done"

# 06 — firewall
{
  echo "### ufw ###"; have ufw && ufw status verbose 2>&1 || echo "ufw not installed"
  echo; echo "### iptables INPUT ###"; have iptables && iptables -L INPUT -n -v 2>&1 | head -60 || echo "iptables n/a"
  echo; echo "### nft ###"; have nft && nft list ruleset 2>&1 | head -60 || echo "nft not installed"
  echo; echo "### docker-proxy listeners (published->host bridge) ###"
  ( have ss && ss -tlpn 2>/dev/null | grep -i docker-proxy ) || echo "(none / ss unavailable)"
} > "$OUT/06_firewall.txt" 2>&1
log "06 firewall done"

# 07 — reconcile live host ports vs documented set
DOC_PORTS="3307 5001 5435 6380 7205 7206 7230 7231 7232 7233 7239 7687 8001 8002 8004 8005 8006 8007 8008 8014 8016 8019 8032 8033 8045 8046 8050 8055 8056 8060 8073 8074 8075 8079 8080 8081 8082 8083 8084 8091 8096 8108 8201 8202 8203 8204 8205 8206 8207 8208 8209 8210 8211 8212 8213 8214 8215 8216 8217 8218 8219 8220 8221 8222 11434"
printf '%s\n' $DOC_PORTS | sort -u > "$OUT/_doc.txt"
awk -F'\t' 'NR>1{print $3}' "$OUT/01_ports_published.tsv" 2>/dev/null | grep -E '^[0-9]+$' | sort -u > "$OUT/_live.txt"
{
  echo "### live published host ports ###"; tr '\n' ' ' < "$OUT/_live.txt"; echo
  echo; echo "### documented but NOT live (missing) ###"; comm -23 "$OUT/_doc.txt" "$OUT/_live.txt" | tr '\n' ' '; echo
  echo; echo "### live but NOT documented (undocumented surface) ###"; comm -13 "$OUT/_doc.txt" "$OUT/_live.txt" | tr '\n' ' '; echo
} > "$OUT/07_doc_reconcile.txt" 2>&1
log "07 doc reconcile done"

# 08 — canonical map
{
  echo "container_port/proto -> host_ip:host_port  (container) [state]"
  awk -F'\t' 'NR>1{printf "%-16s -> %s:%-7s  %-42s [%s]\n",$4"/"$5,$2,$3,$1,$6}' \
    "$OUT/01_ports_published.tsv" 2>/dev/null
} > "$OUT/08_port_map_canonical.txt" 2>&1
log "08 canonical map done"

# 09 — full-range localhost scan
if have nmap; then
  nmap -p- -T4 --open 127.0.0.1 2>/dev/null > "$OUT/09_nmap_localhost_full.txt"
  log "09 nmap full-range localhost done"
else
  echo "nmap not installed — install with: sudo apt-get install -y nmap" > "$OUT/09_nmap_localhost_full.txt"
  log "09 nmap not present (install for full-range scan)"
fi

# 10 — UNION of every listening port
{
  echo "scope	proto	port	detail"
  awk -F'\t' 'NR>1{print "container-published\t"$5"\t"$3"\t"$1" ("$2") cport="$4}' "$OUT/01_ports_published.tsv" 2>/dev/null
  awk -F'\t' 'NR>1{print "container-internal\t"$3"\t"$2"\t"$1" [no host map]"}' "$OUT/01_ports_internal_only.tsv" 2>/dev/null
  awk '/LISTEN|UNCONN/{print "host-listener\t"$1"\t"$5"\t"$0}' "$OUT/04_host_listeners.txt" 2>/dev/null \
    | sed -E 's/\t[^\t]*:([0-9]+)\t/\t\1\t/'
} > "$OUT/10_all_listening_ports_union.tsv" 2>&1
log "10 union built"

# 11 — SUMMARY
NL_N="$(awk 'NR>1' "$OUT/02_ports_nonloopback.tsv" 2>/dev/null | grep -c .)"
COL_N="$(awk 'NR>1' "$OUT/03_ports_collisions.tsv" 2>/dev/null | grep -c .)"
EXT_N="$(grep -cE 'LISTEN|UNCONN' "$OUT/05_host_listeners_external.txt" 2>/dev/null)"
{
  echo "# Port Audit — Verified Snapshot"; echo
  echo "_Auto-generated by msjarvis_port_audit.sh v2 — cite from the presentation repo._"; echo
  echo "| Metric | Value |"; echo "|---|---|"
  echo "| Snapshot (UTC) | $(date -u +%Y-%m-%dT%H:%M:%SZ) |"
  [ -f "$OUT/01_counts.txt" ] && sed 's/^/| /; s/: / | /; s/$/ |/' "$OUT/01_counts.txt"
  echo "| External host listeners | ${EXT_N:-0} |"
  echo
  echo "## Non-loopback container bindings (attack surface)"; echo '```'
  awk 'NR>1' "$OUT/02_ports_nonloopback.tsv" 2>/dev/null || echo "(none)"; echo '```'
  echo "## Host-port collisions"; echo '```'
  awk 'NR>1' "$OUT/03_ports_collisions.tsv" 2>/dev/null || echo "(none)"; echo '```'
  echo "## Live-vs-documented reconcile"; echo '```'
  sed -n '/missing/,$p' "$OUT/07_doc_reconcile.txt" 2>/dev/null; echo '```'
  echo "Artifacts: 01_ports_published.tsv, 01_ports_internal_only.tsv, 02_ports_nonloopback.tsv,"
  echo "03_ports_collisions.tsv, 04_host_listeners.txt, 05_host_listeners_external.txt, 06_firewall.txt,"
  echo "07_doc_reconcile.txt, 08_port_map_canonical.txt, 09_nmap_localhost_full.txt, 10_all_listening_ports_union.tsv."
} > "$OUT/SUMMARY.md" 2>&1
log "11 SUMMARY.md written"

rm -f "$OUT/_inspect.json" "$OUT/_doc.txt" "$OUT/_live.txt" 2>/dev/null
chown -R "$REAL_USER":"$REAL_USER" "$REAL_HOME/audit-snapshots" 2>/dev/null
( cd "$REAL_HOME/audit-snapshots" && tar -czf "portaudit_${TS}.tar.gz" "portaudit_${TS}" ) 2>/dev/null \
  && chown "$REAL_USER":"$REAL_USER" "$REAL_HOME/audit-snapshots/portaudit_${TS}.tar.gz" 2>/dev/null \
  && log "bundled: $REAL_HOME/audit-snapshots/portaudit_${TS}.tar.gz"

echo; echo "==== PORT AUDIT COMPLETE ===="; cat "$OUT/SUMMARY.md"; echo; echo "Folder: $OUT"
