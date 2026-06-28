# Data Stores

> **GENERATED FILE — do not hand-edit.** Rendered from `../04-evidence/facts.json` (snapshot `2026-06-28T23:37:15Z`). To update, re-run the evidence pipeline:
> `PGPASSWORD=… ./04-evidence/scripts/update_evidence.sh` (add `--full` to recount the backup corpus).


Ms. Allis pairs a semantic store (H_App) with a spatial store (H_geo): **H_App ⊗ H_geo = ChromaDB ⊗ PostGIS**. This page reports the *live* state of both, verified read-only on the snapshot date.

## H_App — ChromaDB (semantic / vector)

| Store | Collections | Vectors | Size | Notes |
|---|---|---|---|---|
| **Live (mounted)** | 3 | 204 | — | path `unavailable` |
| **Canonical backup** | 125 | 16,871,654 | 104 GB | verified 2026-06-28T23:37:15Z |

Backup on-disk schema: `embeddings_queue v2`, `metadb v6`, `sysdb v10`.

> **Live vs. canonical:** the mounted store holds **204** vectors while the canonical backup holds **16,871,654**. The live store is a reduced/shell store; the full corpus lives in the backup and is restored/repointed separately.

## H_geo — PostgreSQL / PostGIS (spatial / relational)

| Endpoint | Status | Databases (size) | Role |
|---|---|---|---|
| `host:5432` | ok | gisdb (13 GB); msjarvis (9606 MB); msjarvisgis (1214 MB) |  |
| `host:5433` | ok | msjarvisgis (95 GB); msjarvis (1587 MB) | **spatial body** |
| `container:jarvis-local-resources-db (host 5435)` | ok | msjarvisgis (16 MB) |  |

Spatial body (`host:5433`, `msjarvisgis`): 7 schemas / 725 tables; `wv_tax_parcels_2025` = 1,389,855 rows; `buildings` = 2,121,130 rows. Row counts are live `count(*)` values; planner statistics may read 0 if tables were bulk-loaded without `ANALYZE`.

---
*Source: `../04-evidence/facts.json`. Regenerate; do not edit by hand.*
