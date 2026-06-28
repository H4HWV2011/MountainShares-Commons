# Infrastructure Snapshot — Verified Live System

**System:** Ms. Allis (internal: Jarvis) — Harmony for Hope, Inc. / Kidd's Technical Services
**Host:** cakidd-Legion-5-16IRX9 (Lenovo Legion 5)
**Snapshot date:** 2026-06-28
**Method:** Read-only audit of the running system. Every figure below is machine-generated from a dated artifact and is reproducible by re-running the audit scripts. This file is the single source of truth for the presentation repo; do not hand-edit numbers — regenerate them.

> **Reading rule for this document.** A claim is only listed as *verified* if it came from the live system on the snapshot date. Where the existing documentation disagrees with the live system, the live system wins and the gap is recorded under "Documentation vs. reality."

---

## 1. Headline numbers (verified live, 2026-06-28)

| Metric | Verified value | Source artifact |
|---|---|---|
| Running containers | **158** | portaudit_20260628_133930 |
| Published port bindings | 117 | portaudit_20260628_133930 |
| Internal-only container ports | 61 | portaudit_20260628_133930 |
| Distinct host ports | 116 | portaudit_20260628_133930 |
| Host-port collisions | 0 | portaudit_20260628_133930 |
| Non-loopback container bindings | 1 (BBB :8016) | portaudit_20260628_133930 |
| Ollama models | ~37 | audit_20260628_132144 |
| ChromaDB — live store | 3 collections / **204 vectors** | audit_20260628_132144 |
| ChromaDB — canonical corpus (backup) | 125 collections / **16,871,654 vectors** | chromaverify_20260628_134458 |
| PostGIS spatial body (real) | `msjarvisgis` **95 GB**, 7 schemas / 725 tables @ host :5433 | psql probe, this session |
| Host firewall (ufw) | **inactive** | portaudit_20260628_133930 / 06_firewall.txt |
| Public URL | https://egeria.mountainshares.us → 200 (Cloudflare → Caddy) | audit_20260628_132144 |

---

## 2. The two Hilbert bodies — where the real data lives

The architecture pairs a semantic store (H_App) with a spatial store (H_geo): **H_App ⊗ H_geo = ChromaDB ⊗ PostGIS**. There is exactly one ChromaDB and the spatial half is PostgreSQL/PostGIS — not a second Chroma. Confirmed: one `jarvis-chroma` container, and all 11+ service references resolve to `jarvis-chroma:8000` / `127.0.0.1:8002`.

**Critical pattern:** for *both* bodies, the live/running store is a near-empty shell while the populated corpus lives on a separate backend.

### 2a. H_App — ChromaDB (semantic / vector)

| Store | Location | Size | Collections | Vectors |
|---|---|---|---|---|
| **Live (mounted)** | `/mnt/nvme1/msjarvis-data/chroma-live` (via `/home/ms-jarvis/.../persistent/chroma`) | 3.6 MB | 3 | **204** |
| **Canonical corpus** | `chroma-live-bk-20260623-0834` and `chroma-live.bak-20260626` | 96 GB each | 125 | **16,871,654** |

- The two 96 GB backups are **byte-identical** (same size to the byte, same mtime to the nanosecond) — effectively one backup with two filenames; treat as a single restore source.
- Schema generation: `sysdb v10 / metadb v6 / embeddings_queue v2` — **matches the live `chromadb==1.0.0` store**, so a restore is a clean copy-in (no migration).
- Corpus composition: `geospatialfeatures` (12.39 M) + `gbim_entities` (3.54 M) = **94%** of all vectors — geometry, not retrieval documents. The knowledge-RAG collections retrieval depends on are the small ones (`governance_rag` 643, `commons_rag` 343, `psychological_rag` 968, `spiritual_texts` 5,557, and the `*_rag` set) — all present in the backup. "16.87 M restored" and "retrieval works" are different claims; the second depends on these small collections plus query-side embedding-model parity.

### 2b. H_geo — PostgreSQL / PostGIS (spatial / relational)

Three live PostgreSQL endpoints hold differently-populated copies. **The real spatial body is on host Postgres :5433.**

| Endpoint | Process | `msjarvisgis` | other DBs | Role |
|---|---|---|---|---|
| host `:5433` (pid 2301) | host postgres | **95 GB** ← real | `msjarvis` 1.5 GB | **canonical spatial body** |
| host `:5432` (pid 2300) | host postgres | 1.2 GB (partial) | `gisdb` 13 GB (owner `gbim`), `msjarvis` 9.4 GB | mixed; holds the large relational DBs |
| container `:5435`→5432 | `jarvis-local-resources-db` (postgis:15-3.4) | 16 MB (shell) | — | near-empty rebuild store |
| host `:5434` | — | no response | — | not running |

- `msjarvisgis` @5433: 7 schemas, 725 tables, full PostGIS geometry registry, GBIM worldview/beliefs/evidence/graph stack.
- **Confirmed real rows** (stats read 0 only because tables were bulk-loaded and never `ANALYZE`d; disk footprint is the truth): `raw.wv_tax_parcels_2025` = **1,389,855**, `public.buildings` = **2,121,130**. Largest tables by disk: `gbim_worldview_entity` 47 GB, `gbimbeliefnormalized` 21 GB, `gbim_beliefs` 3.3 GB.
- Other DB containers present: MySQL (:3307), Neo4j (:7687), Redis (:6380).

---

## 3. Security posture (as of 2026-06-28)

**One-sentence statement for external readers:** *ufw is inactive (no host firewall); the container fleet is loopback-bound except the Blood-Brain Barrier on 8016, but at the host-process layer two PostgreSQL engines — including the 95 GB spatial corpus on :5433 — and several Python/uvicorn services listen on `0.0.0.0`, making them reachable from the local network; public internet access is mediated only by the Cloudflare tunnel → Caddy, and the database ports are not tunneled, so exposure is LAN-scoped unless the router forwards them (unverified).*

Exposed on `0.0.0.0` with no firewall (from `05_host_listeners_external.txt`):

| Port | Process | Note |
|---|---|---|
| 5432 | postgres (pid 2300) | host DB: `gisdb` 13 GB + `msjarvis` 9.4 GB — **open to LAN** |
| 5433 | postgres (pid 2301) | host DB: `msjarvisgis` **95 GB spatial corpus — open to LAN** |
| 8016 | docker-proxy | Blood-Brain Barrier (IPv4 + IPv6) |
| 8051, 8018, 8013, 8076, 8300, 9002, 4021 | python3 / uvicorn | host-process services, not in the container fleet |
| 3002 | next-server | Next.js dev server |
| 80 | caddy | expected (public reverse proxy) |

The container fleet itself is correctly loopback-bound (127.0.0.1) — the exposure is entirely at the host-process layer, which the documentation does not describe.

---

## 4. Documentation vs. reality (work-repo corrections)

These are gaps between the published thesis/docs and the live system. The presentation repo must use the verified column; the work repo's affected sections are inaccurate as written.

| Claim in docs | Documented | Verified live | Severity |
|---|---|---|---|
| Production databases | `msallis-db` (16 GB) + `postgis-forensic` (17 GB) | **Neither name exists.** Real: `msjarvisgis` 95 GB @5433, `msjarvis` 9.4 GB @5432, `gisdb` 13 GB @5432 | High |
| ChromaDB vector total | 5.4 M / 6.74 M / 7.9 M (8+ conflicting figures) | **16,871,654** (backup) / 204 (live) | High |
| Container count | 79–112 | **158 running** | Medium |
| Ollama models | 26 | ~37 | Low |
| Port exposure | "all services 127.0.0.1, zero 0.0.0.0" | True for containers; **false at host layer; ufw off** | High (security) |
| Auth port | 8055 | live auth publishes **8096→8091** | Medium |
| Pipeline port map | ~40 named ports | **116 distinct host ports** published | Medium |
| GeoDB wiring | services use the production GeoDB | services point at `msjarvis-db:5432` → container `jarvis-msjarvis-db` which is **not running** | High |
| System name | "Ms. Allis" | live infra is entirely `jarvis-*` / `nbb_*` / `msjarvis-rebuild-*`; "Allis" is documentation-only | Medium (presentation) |
| GBIM expansion | "Geospatial Belief Information Model" | docs also contain "General Biological Intelligence Model" and "GeoBelief Information Model" | Medium |

---

## 5. Open items / remediation backlog (decisions pending — owner: Carrie / Perplexity)

Listed for the record. None are actions taken in this audit; all are read-only findings. Sequencing and execution are the owners' call.

1. **ChromaDB restore** — repoint the live store, or copy the 96 GB backup into the live path, so retrieval has the real corpus. Schema already matches 1.0.0. *(In progress in the rag-server workstream.)*
2. **PostGIS repoint** — the GeoDB-consuming services target a non-running host (`jarvis-msjarvis-db`); the real corpus is on host :5433. Decide per-database which endpoint is canonical (spatial → :5433; large relational → :5432).
3. **Embedding-model parity** — confirm the rag-server query model/dimension matches what wrote the 16.87 M backup (docs: all-minilm, 384-dim), or retrieval returns garbage despite a "successful" restore.
4. **Firewall** — ufw is off and two Postgres engines listen on `0.0.0.0`. Simplest mitigation is default-deny inbound; schedule outside an active rebuild. Confirm the router does not forward 5432/5433.
5. **BBB binding** — `jarvis-blood-brain-barrier` binds `0.0.0.0:8016`; rebind to 127.0.0.1 if external reach is not required.
6. **Stale statistics** — the 95 GB `msjarvisgis` tables report 0 rows to the planner (never analyzed); `ANALYZE` would restore query-planner accuracy. Cosmetic for audit, real for query performance.

---

## 6. Artifact index (provenance)

Every number in this document traces to one of these dated, reproducible artifacts under `~/audit-snapshots/`:

| Artifact | Produced by | Supplies |
|---|---|---|
| `audit_20260628_132144/` | `msjarvis_audit_snapshot.sh` | container count, ollama, live chroma |
| `portaudit_20260628_133930/` | `msjarvis_port_audit.sh` (v2) | full port map, non-loopback, host listeners, firewall, doc reconcile |
| `chromaverify_20260628_134458/` | `msjarvis_chroma_backup_verify.sh` | backup collection list, 16,871,654 vectors, schema version |
| (this session, ad-hoc psql) | read-only `psql` probes | host Postgres DB sizes, row counts, `msjarvis-db` resolution |

To regenerate this snapshot on a later date, re-run the three scripts and update §1–§3 from their output.

---

*Prepared for the Ms. Allis presentation repository. Point-in-time verified snapshot, 2026-06-28. Numbers are regenerable; do not hand-maintain. The work/lab repository (msjarvis-public-docs) remains the full provenance record; this document is the audited storefront and should cross-link to it.*
