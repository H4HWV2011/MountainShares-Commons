# Data Stores

> **GENERATED FILE — do not hand-edit.** Rendered from `../04-evidence/facts.json` (snapshot `2026-06-29T03:53:45Z`). To update, re-run the evidence pipeline:
> `PGPASSWORD=… ./04-evidence/scripts/update_evidence.sh` (add `--full` to recount the backup corpus).


Ms. Allis runs a three-body memory: a semantic store (H_App / ChromaDB), a spatial store (H_geo / PostGIS), and a temporal body (H_t / Redis) — **H_App ⊗ H_geo ⊗ H_t**. This page reports the *live* state of all three, verified read-only on the snapshot date.

## H_App — ChromaDB (semantic / vector)

| Store | Collections | Vectors | Size | Notes |
|---|---|---|---|---|
| **Live (mounted)** | 125 | 16,871,677 | — | path `/mnt/nvme1/msjarvis-data/chroma-live-bk-20260623-0834` |
| **Canonical backup** | 125 | 16,871,677 | 104 GB | verified 2026-06-29T03:53:45Z |

Backup on-disk schema: `embeddings_queue v2`, `metadb v6`, `sysdb v10`.

## H_geo — PostgreSQL / PostGIS (spatial / relational)

| Endpoint | Status | Databases (size) | Role |
|---|---|---|---|
| `host:5432` | ok | gisdb (13 GB); msjarvis (9606 MB); msjarvisgis (1214 MB); local_resources (7425 kB) |  |
| `host:5433` | ok | msjarvisgis (95 GB); msjarvis (1587 MB) | **spatial body** |
| `container:jarvis-local-resources-db (host 5435)` | ok | msjarvisgis (16 MB) |  |

Spatial body (`host:5433`, `msjarvisgis`): 7 schemas / 725 tables; `wv_tax_parcels_2025` = 1,389,855 rows; `buildings` = 2,121,130 rows. Row counts are live `count(*)` values; planner statistics may read 0 if tables were bulk-loaded without `ANALYZE`.

## H_t — temporal body (Redis)

| Service | Store | Timelines | Events |
|---|---|---|---|
| `jarvis-hilbert-time` | Redis | 4 | 35 |

The temporal body records *when* every ingest and query occurred as ordered, decay-weighted timelines (Redis sorted sets), feeding a half-life recency weight into retrieval scoring. It holds no embeddings.

---
*Source: `../04-evidence/facts.json`. Regenerate; do not edit by hand.*
