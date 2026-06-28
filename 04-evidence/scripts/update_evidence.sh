#!/usr/bin/env bash
# update_evidence.sh — regenerate the evidence + tech pages in one step.
# Run from the repo root. Passes flags (e.g. --full) through to the collector.
# Host PostgreSQL needs a password: PGPASSWORD=… ./04-evidence/scripts/update_evidence.sh
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
python3 "$HERE/collect_evidence.py" "$@" || { echo "collect failed"; exit 1; }
python3 "$HERE/render_tech_pages.py"      || { echo "render failed"; exit 1; }
echo
echo "Review the generated pages, then commit:"
echo "  git add 03-technology/data-stores.md 03-technology/port-map.md 04-evidence/facts.json 04-evidence/snapshots/latest"
echo "  git commit -m \"Tech: regenerate data-stores + port-map from evidence snapshot\""
echo "  git push"
