#!/usr/bin/env bash
# msjarvis_chroma_backup_verify.sh
# READ-ONLY verification of ChromaDB backup stores. Does NOT mount, restore,
# restart, or touch the running stack or the rag-server rebuild.
# Opens each chroma.sqlite3 with mode=ro&immutable=1 (safe for static backups).
#
# Usage:
#   ./msjarvis_chroma_backup_verify.sh                 # default: the two ~96GB backups
#   ./msjarvis_chroma_backup_verify.sh --integrity     # also run quick_check (slow: full read)
#   ./msjarvis_chroma_backup_verify.sh /path/a/chroma.sqlite3 /path/b/chroma.sqlite3
#
# NOTE: per-collection counts and quick_check scan large tables; on a 96GB store
# expect minutes. Default run skips quick_check (enable with --integrity).

export LC_ALL=C
INTEGRITY=0
PATHS=()
for a in "$@"; do
  case "$a" in
    --integrity) INTEGRITY=1 ;;
    *) PATHS+=("$a") ;;
  esac
done
if [ "${#PATHS[@]}" -eq 0 ]; then
  PATHS=(
    "/mnt/nvme1/msjarvis-data/chroma-live-bk-20260623-0834/chroma.sqlite3"
    "/mnt/nvme1/msjarvis-data/chroma-live.bak-20260626/chroma.sqlite3"
  )
fi

command -v sqlite3 >/dev/null 2>&1 || { echo "sqlite3 not installed: sudo apt-get install -y sqlite3"; exit 1; }

TS="$(date +%Y%m%d_%H%M%S)"
OUT="$HOME/audit-snapshots/chromaverify_${TS}"
mkdir -p "$OUT" || { echo "cannot create $OUT"; exit 1; }
REPORT="$OUT/VERIFY.md"
echo "Verify dir: $OUT"

# read-only query helper
roq() { sqlite3 "file:$1?mode=ro&immutable=1" "$2" 2>&1; }

{
  echo "# ChromaDB Backup Verification"
  echo
  echo "_Read-only. No mount/restore/restart performed. Generated $(date -u +%Y-%m-%dT%H:%M:%SZ)._"
  echo
} > "$REPORT"

for DB in "${PATHS[@]}"; do
  echo "==================== $DB ===================="
  {
    echo "## $(basename "$(dirname "$DB")")/$(basename "$DB")"
    echo
    echo "- path: \`$DB\`"
    if [ ! -f "$DB" ]; then
      echo "- **MISSING** — file not found"; echo; continue
    fi
    SZ=$(stat -c '%s' "$DB" 2>/dev/null); SZH=$(numfmt --to=iec "$SZ" 2>/dev/null || echo "$SZ")
    echo "- size: $SZH ($SZ bytes)"
    echo "- mtime: $(stat -c '%y' "$DB" 2>/dev/null)"

    # tables present
    TBLS="$(roq "$DB" ".tables")"
    echo "- tables: \`$(echo "$TBLS" | tr -s ' \n' ' ' | sed 's/^ //;s/ $//')\`"

    # schema generation via migrations (best effort)
    MIG="$(roq "$DB" "SELECT COALESCE(MAX(version),'?') FROM migrations;")"
    echo "- migrations_max_version: $MIG"
    MIGROWS="$(roq "$DB" "SELECT dir||' v'||version||' '||filename FROM migrations ORDER BY dir,version;")"

    # collections + per-collection vector counts
    echo
    echo "### collections (name : vector_count)"
    echo '```'
    CC="$(roq "$DB" "SELECT c.name, COUNT(e.id) AS n
                     FROM collections c
                     LEFT JOIN segments s ON s.collection = c.id
                     LEFT JOIN embeddings e ON e.segment_id = s.id
                     GROUP BY c.name ORDER BY n DESC;")"
    if echo "$CC" | grep -qiE 'error|no such'; then
      echo "join query failed, falling back to raw counts:"
      echo "collections: $(roq "$DB" "SELECT COUNT(*) FROM collections;")"
      echo "names: $(roq "$DB" "SELECT group_concat(name,', ') FROM collections;")"
      echo "total embeddings: $(roq "$DB" "SELECT COUNT(*) FROM embeddings;")"
    else
      echo "$CC" | sed 's/|/ : /'
    fi
    echo '```'

    COLN="$(roq "$DB" "SELECT COUNT(*) FROM collections;")"
    TOTV="$(roq "$DB" "SELECT COUNT(*) FROM embeddings;")"
    echo "- collection_count: $COLN"
    echo "- total_vectors: $TOTV"

    if [ "$INTEGRITY" -eq 1 ]; then
      echo "- quick_check: (running, this reads the whole file)…"
      QC="$(roq "$DB" "PRAGMA quick_check;")"
      echo "- quick_check_result: $QC"
    else
      echo "- quick_check: skipped (run with --integrity to verify corruption)"
    fi

    echo
    echo "<details><summary>migrations detail</summary>"
    echo; echo '```'; echo "$MIGROWS"; echo '```'; echo "</details>"
    echo
  } | tee -a "$REPORT"
done

# side-by-side comparison line for the two backups (if both present)
{
  echo "## Comparison"
  echo
  echo "| backup | size | collections | total_vectors | migr_ver |"
  echo "|---|---|---|---|---|"
  for DB in "${PATHS[@]}"; do
    [ -f "$DB" ] || { echo "| $(basename "$(dirname "$DB")") | MISSING | - | - | - |"; continue; }
    SZH=$(numfmt --to=iec "$(stat -c '%s' "$DB")" 2>/dev/null)
    COLN="$(roq "$DB" "SELECT COUNT(*) FROM collections;")"
    TOTV="$(roq "$DB" "SELECT COUNT(*) FROM embeddings;")"
    MIG="$(roq "$DB" "SELECT COALESCE(MAX(version),'?') FROM migrations;")"
    echo "| $(basename "$(dirname "$DB")") | $SZH | $COLN | $TOTV | $MIG |"
  done
} | tee -a "$REPORT"

echo
echo "==== VERIFICATION COMPLETE ===="
echo "Report: $REPORT"
