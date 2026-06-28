#!/usr/bin/env bash
# msjarvis_audit_snapshot.sh
# Live-system ground-truth audit -> dated artifact folder for the presentation repo.
# Non-fatal by design: every probe records its result; a missing container or auth gap
# is logged, not aborted. Does NOT touch jarvis-rag-server.
# Adjust DB users/passwords/ports in the CONFIG block if your setup differs.

# ---- CONFIG (edit if needed) -------------------------------------------------
CHROMA_HOST="127.0.0.1"; CHROMA_PORT="8002"
PG_PORTS="5432 5433 5434 5435"          # host postgres candidates to probe
PG_USERS="postgres allis jarvis"        # users to try (best effort)
PUBLIC_URL="https://egeria.mountainshares.us"
# ------------------------------------------------------------------------------

TS="$(date +%Y%m%d_%H%M%S)"
OUT="$HOME/audit-snapshots/audit_${TS}"
mkdir -p "$OUT" || { echo "cannot create $OUT"; exit 1; }
echo "Audit dir: $OUT"

log() { echo "[$(date +%H:%M:%S)] $*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# 00 — meta -------------------------------------------------------------------
{
  echo "snapshot_utc: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "snapshot_local: $(date +%Y-%m-%dT%H:%M:%S%z)"
  echo "host: $(hostname)"
  echo "uname: $(uname -a)"
  echo "docker: $(docker --version 2>/dev/null)"
  echo "compose: $(docker compose version 2>/dev/null | head -1)"
} > "$OUT/00_meta.txt" 2>&1
log "00 meta done"

# 01 — containers -------------------------------------------------------------
docker ps --no-trunc > "$OUT/01_docker_ps_full.txt" 2>&1
docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' \
  | sort > "$OUT/01_containers_parsed.tsv" 2>&1
RUNNING="$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')"
TOTAL_ALL="$(docker ps -aq 2>/dev/null | wc -l | tr -d ' ')"
echo "$RUNNING" > "$OUT/01_running_count.txt"
{
  echo "running_containers: $RUNNING"
  echo "all_containers_incl_stopped: $TOTAL_ALL"
  echo "--- status histogram (running) ---"
  docker ps --format '{{.Status}}' | sed 's/ (.*//' | awk '{print $1}' | sort | uniq -c | sort -rn
} > "$OUT/01_counts.txt" 2>&1
log "01 containers done (running=$RUNNING)"

# 02 — non-loopback bindings (catches 0.0.0.0 exposures) ----------------------
docker ps --format '{{.Names}}\t{{.Ports}}' \
  | grep -E '0\.0\.0\.0|\[::\]' > "$OUT/02_nonloopback_bindings.txt" 2>&1
if [ -s "$OUT/02_nonloopback_bindings.txt" ]; then
  log "02 WARNING: non-loopback bindings found (see 02_nonloopback_bindings.txt)"
else
  echo "none" > "$OUT/02_nonloopback_bindings.txt"
  log "02 bindings clean"
fi

# 03 — health / not-running ---------------------------------------------------
{
  echo "=== unhealthy ==="
  docker ps --filter health=unhealthy --format '{{.Names}}\t{{.Status}}'
  echo "=== restarting ==="
  docker ps --filter status=restarting --format '{{.Names}}\t{{.Status}}'
  echo "=== health: starting ==="
  docker ps --format '{{.Names}}\t{{.Status}}' | grep -i 'health: starting'
  echo "=== exited / stopped ==="
  docker ps -a --filter status=exited --format '{{.Names}}\t{{.Status}}'
} > "$OUT/03_health.txt" 2>&1
log "03 health done"

# 04 — images / versions ------------------------------------------------------
docker ps --format '{{.Image}}' | sort | uniq -c | sort -rn > "$OUT/04_images.txt" 2>&1
log "04 images done"

# 05 — ollama models ----------------------------------------------------------
if docker ps --format '{{.Names}}' | grep -q '^jarvis-ollama$'; then
  docker exec jarvis-ollama ollama list > "$OUT/05_ollama_models.txt" 2>&1
  MODELS="$(grep -c . "$OUT/05_ollama_models.txt" 2>/dev/null)"
  # subtract header line if present
  [ "$MODELS" -gt 0 ] 2>/dev/null && MODELS=$((MODELS-1))
  echo "ollama_model_count_approx: $MODELS" >> "$OUT/05_ollama_models.txt"
  log "05 ollama done (~$MODELS models)"
else
  echo "jarvis-ollama not running" > "$OUT/05_ollama_models.txt"
  log "05 ollama container not found"
fi

# 06 — ChromaDB collections + vector totals (stdlib only, no deps) ------------
python3 - "$CHROMA_HOST" "$CHROMA_PORT" > "$OUT/06_chroma.txt" 2>&1 <<'PY'
import sys, json, urllib.request
host, port = sys.argv[1], sys.argv[2]
def get(url):
    return json.load(urllib.request.urlopen(url, timeout=15))
roots = [
    "http://%s:%s/api/v2/tenants/default_tenant/databases/default_database/collections" % (host, port),
    "http://%s:%s/api/v1/collections" % (host, port),
]
cols=None; used=None
for r in roots:
    try:
        cols=get(r); used=r; break
    except Exception as e:
        print("try_failed:", r, "->", e)
if cols is None:
    print("CHROMA_UNREACHABLE")
    sys.exit(0)
print("endpoint_used:", used)
print("collection_count:", len(cols))
total=0
for c in cols:
    cid=c.get("id"); name=c.get("name")
    n="?"
    if cid:
        for cu in (used.rsplit("/collections",1)[0]+"/collections/"+cid+"/count",):
            try:
                n=get(cu)
            except Exception as e:
                n="ERR:%s"%e
    print("  %-40s %s" % (str(name), n))
    if isinstance(n,int): total+=n
print("TOTAL_VECTORS:", total)
PY
grep -E '^collection_count:|^TOTAL_VECTORS:|CHROMA_UNREACHABLE' "$OUT/06_chroma.txt" > "$OUT/06_chroma_summary.txt" 2>&1
log "06 chroma done"

# 07 — Postgres / PostGIS (host probes + container exec) ----------------------
{
  echo "### host port reachability (pg_isready) ###"
  if have pg_isready; then
    for p in $PG_PORTS; do
      printf "port %s: " "$p"; pg_isready -h 127.0.0.1 -p "$p" 2>&1
    done
  else
    echo "pg_isready not installed; skipping host reachability"
  fi

  echo; echo "### host db lists (best effort, may need password) ###"
  if have psql; then
    for p in $PG_PORTS; do
      for u in $PG_USERS; do
        echo "--- port $p user $u ---"
        psql "host=127.0.0.1 port=$p user=$u connect_timeout=4" -At -c \
          "select datname, pg_size_pretty(pg_database_size(datname)) from pg_database order by 1;" 2>&1 | head -40
      done
    done
  else
    echo "psql not installed on host; skipping host db lists"
  fi

  echo; echo "### containerized postgres (docker exec) ###"
  for c in $(docker ps --format '{{.Names}} {{.Image}}' | grep -iE 'postgis|postgres' | awk '{print $1}'); do
    echo "=== container: $c ==="
    for u in $PG_USERS; do
      OUTP="$(docker exec "$c" psql -U "$u" -At -c \
        "select datname, pg_size_pretty(pg_database_size(datname)) from pg_database order by 1;" 2>&1)"
      if echo "$OUTP" | grep -qiE 'role .* does not exist|fatal|denied'; then
        continue
      fi
      echo "[user=$u]"; echo "$OUTP" | head -40; break
    done
  done
} > "$OUT/07_postgres.txt" 2>&1
log "07 postgres done"

# 08 — naming reality (jarvis vs allis) ---------------------------------------
{
  echo "container names containing 'jarvis': $(docker ps --format '{{.Names}}' | grep -ci jarvis)"
  echo "container names containing 'allis':  $(docker ps --format '{{.Names}}' | grep -ci allis)"
  echo "--- compose grep (if compose file present in CWD) ---"
  for f in docker-compose.yml docker-compose.yaml compose.yml; do
    [ -f "$f" ] && { echo "$f: jarvis=$(grep -ci jarvis "$f") allis=$(grep -ci allis "$f")"; }
  done
} > "$OUT/08_naming.txt" 2>&1
log "08 naming done"

# 09 — public endpoint auth check (harmless HEAD) -----------------------------
if have curl; then
  {
    echo "GET $PUBLIC_URL/  -> $(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$PUBLIC_URL/" 2>&1)"
    echo "GET $PUBLIC_URL/chat (unauth, expect 401) -> $(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$PUBLIC_URL/chat" 2>&1)"
  } > "$OUT/09_public_endpoint.txt" 2>&1
else
  echo "curl not installed" > "$OUT/09_public_endpoint.txt"
fi
log "09 public endpoint done"

# 10 — canonical SNAPSHOT.md (the citable artifact) ---------------------------
CHROMA_TOTAL="$(grep '^TOTAL_VECTORS:' "$OUT/06_chroma.txt" | awk '{print $2}')"
CHROMA_COLS="$(grep '^collection_count:' "$OUT/06_chroma.txt" | awk '{print $2}')"
NONLOOP="$(grep -vc '^none$' "$OUT/02_nonloopback_bindings.txt" 2>/dev/null)"
{
  echo "# Verified System Snapshot"
  echo
  echo "_Auto-generated by msjarvis_audit_snapshot.sh — do not hand-edit. Cite this file from the presentation repo._"
  echo
  echo "| Metric | Value |"
  echo "|---|---|"
  echo "| Snapshot (UTC) | $(date -u +%Y-%m-%dT%H:%M:%SZ) |"
  echo "| Host | $(hostname) |"
  echo "| Running containers | ${RUNNING:-?} |"
  echo "| Containers (incl. stopped) | ${TOTAL_ALL:-?} |"
  echo "| Non-loopback bindings | ${NONLOOP:-?} (see 02) |"
  echo "| Ollama models (approx) | $(grep ollama_model_count_approx "$OUT/05_ollama_models.txt" | awk -F': ' '{print $2}') |"
  echo "| ChromaDB collections | ${CHROMA_COLS:-?} |"
  echo "| ChromaDB total vectors | ${CHROMA_TOTAL:-?} |"
  echo "| Public URL / (HTTP) | $(grep ' / ' "$OUT/09_public_endpoint.txt" | awk '{print $NF}') |"
  echo "| Public /chat unauth | $(grep '/chat' "$OUT/09_public_endpoint.txt" | awk '{print $NF}') |"
  echo
  echo "Artifacts in this folder: 00_meta, 01_containers_parsed.tsv, 02_nonloopback_bindings,"
  echo "03_health, 04_images, 05_ollama, 06_chroma, 07_postgres, 08_naming, 09_public_endpoint."
} > "$OUT/SNAPSHOT.md" 2>&1
log "10 SNAPSHOT.md written"

# 11 — bundle -----------------------------------------------------------------
( cd "$HOME/audit-snapshots" && tar -czf "audit_${TS}.tar.gz" "audit_${TS}" ) 2>/dev/null \
  && log "bundled: $HOME/audit-snapshots/audit_${TS}.tar.gz"

echo
echo "==== AUDIT COMPLETE ===="
cat "$OUT/SNAPSHOT.md"
echo
echo "Folder: $OUT"
echo "Bundle: $HOME/audit-snapshots/audit_${TS}.tar.gz"
