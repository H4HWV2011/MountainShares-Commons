# Port Map

> **GENERATED FILE — do not hand-edit.** Rendered from `../04-evidence/facts.json` (snapshot `2026-06-29T03:40:57Z`). To update, re-run the evidence pipeline:
> `PGPASSWORD=… ./04-evidence/scripts/update_evidence.sh` (add `--full` to recount the backup corpus).


Complete published port surface of the live container fleet, verified read-only.

| Metric | Value |
|---|---|
| Running containers | 158 |
| Published bindings | 116 |
| Internal-only ports | 61 |
| Distinct host ports | 116 |
| Host-port collisions | 0 |
| Non-loopback bindings | 0 |
| Firewall (ufw) | active |
| Public URL / (HTTP) | 200 |

## Non-loopback bindings (network-reachable surface)

All published bindings are loopback-only (127.0.0.1).

## Full canonical port map

<details><summary>All published ports (container_port → host_ip:host_port)</summary>

```
3306/tcp         -> 127.0.0.1:3307     mysql
4002/tcp         -> 127.0.0.1:4002     jarvis-fifth-dgm
5001/tcp         -> 127.0.0.1:5001     ipfs
5001/tcp         -> 127.0.0.1:5015     jarvis-rag-router
5432/tcp         -> 127.0.0.1:5435     jarvis-local-resources-db
6379/tcp         -> 127.0.0.1:6380     jarvis-redis
7012/tcp         -> 127.0.0.1:7012     jarvis-woah
7205/tcp         -> 127.0.0.1:7205     jarvis-gbim-query-router
7206/tcp         -> 127.0.0.1:7206     jarvis-gbim-benefit-indexer
7300/tcp         -> 127.0.0.1:7300     jarvis-ms-coordinator
7474/tcp         -> 127.0.0.1:7475     neo4j
7687/tcp         -> 127.0.0.1:7687     neo4j
8001/tcp         -> 127.0.0.1:8001     jarvis-unified-gateway
8000/tcp         -> 127.0.0.1:8002     jarvis-chroma
8003/tcp         -> 127.0.0.1:8003     jarvis-rag-server
8004/tcp         -> 127.0.0.1:8004     jarvis-gis-rag
8005/tcp         -> 127.0.0.1:8005     jarvis-spiritual-rag
8006/tcp         -> 127.0.0.1:8006     jarvis-local-resources
8007/tcp         -> 127.0.0.1:8007     jarvis-intake-service
8008/tcp         -> 127.0.0.1:8008     jarvis-20llm-production
8010/tcp         -> 127.0.0.1:8010     jarvis-wv-entangled-gateway
8011/tcp         -> 127.0.0.1:8011     jarvis-hippocampus
8014/tcp         -> 127.0.0.1:8014     jarvis-steward
8015/tcp         -> 127.0.0.1:8015     jarvis-nbb-i-containers-2
8016/tcp         -> 127.0.0.1:8016     jarvis-blood-brain-barrier
8019/tcp         -> 127.0.0.1:8019     jarvis-psychology-services
8020/tcp         -> 127.0.0.1:8020     jarvis-consciousness-bridge
8025/tcp         -> 127.0.0.1:8025     jarvis-toroidal
8025/tcp         -> 127.0.0.1:8026     jarvis-phi-probe
8030/tcp         -> 127.0.0.1:8030     jarvis-semaphore
8032/tcp         -> 127.0.0.1:8032     jarvis-aaacpe-rag
8033/tcp         -> 127.0.0.1:8033     jarvis-aaacpe-scraper
8045/tcp         -> 127.0.0.1:8045     jarvis-kyc-vault
8046/tcp         -> 127.0.0.1:8046     jarvis-provenance
8050/tcp         -> 127.0.0.1:8050     jarvis-main-brain
8056/tcp         -> 127.0.0.1:8056     jarvis-memory
8060/tcp         -> 127.0.0.1:8060     jarvis-session-sidecar
8073/tcp         -> 127.0.0.1:8073     jarvis-eeg-delta
8074/tcp         -> 127.0.0.1:8074     jarvis-eeg-theta
8075/tcp         -> 127.0.0.1:8075     jarvis-eeg-beta
8079/tcp         -> 127.0.0.1:8079     jarvis-stewardship-scheduler
8080/tcp         -> 127.0.0.1:8080     jarvis-ms-indexer
8081/tcp         -> 127.0.0.1:8081     jarvis-commons-gamification
8082/tcp         -> 127.0.0.1:8082     jarvis-dao-governance
8083/tcp         -> 127.0.0.1:8083     jarvis-ms-analytics
8084/tcp         -> 127.0.0.1:8084     jarvis-community-stake-registry
8091/tcp         -> 127.0.0.1:8091     jarvis-constitutional-guardian
8091/tcp         -> 127.0.0.1:8096     jarvis-auth-api
8099/tcp         -> 127.0.0.1:8099     jarvis-crypto-policy
7005/tcp         -> 127.0.0.1:8101     nbb-i-containers
8010/tcp         -> 127.0.0.1:8102     nbb_consciousness_containers
8010/tcp         -> 127.0.0.1:8103     nbb_spiritual_root
8010/tcp         -> 127.0.0.1:8104     nbb_woah_algorithms
8010/tcp         -> 127.0.0.1:8105     nbb_prefrontal_cortex
8010/tcp         -> 127.0.0.1:8106     nbb_heteroglobulin_transport
8010/tcp         -> 127.0.0.1:8107     nbb_mother_carrie_protocols
80/tcp           -> 127.0.0.1:8108     nbb_pituitary_gland
8010/tcp         -> 127.0.0.1:8109     nbb_spiritual_maternal_integration
8010/tcp         -> 127.0.0.1:8112     nbb_subconscious
8201/tcp         -> 127.0.0.1:8201     llm1-proxy
8202/tcp         -> 127.0.0.1:8202     llm2-proxy
8203/tcp         -> 127.0.0.1:8203     llm3-proxy
8204/tcp         -> 127.0.0.1:8204     llm4-proxy
8205/tcp         -> 127.0.0.1:8205     llm5-proxy
8206/tcp         -> 127.0.0.1:8206     llm6-proxy
8207/tcp         -> 127.0.0.1:8207     llm7-proxy
8208/tcp         -> 127.0.0.1:8208     llm8-proxy
8209/tcp         -> 127.0.0.1:8209     llm9-proxy
8210/tcp         -> 127.0.0.1:8210     llm10-proxy
8211/tcp         -> 127.0.0.1:8211     llm11-proxy
8212/tcp         -> 127.0.0.1:8212     llm12-proxy
8213/tcp         -> 127.0.0.1:8213     llm13-proxy
8214/tcp         -> 127.0.0.1:8214     llm14-proxy
8215/tcp         -> 127.0.0.1:8215     llm15-proxy
8216/tcp         -> 127.0.0.1:8216     llm16-proxy
8217/tcp         -> 127.0.0.1:8217     llm17-proxy
8218/tcp         -> 127.0.0.1:8218     llm18-proxy
8219/tcp         -> 127.0.0.1:8219     llm19-proxy
8220/tcp         -> 127.0.0.1:8220     llm20-proxy
8221/tcp         -> 127.0.0.1:8221     llm21-proxy
8222/tcp         -> 127.0.0.1:8222     llm22-proxy
8010/tcp         -> 127.0.0.1:8301     nbb_blood_brain_barrier
8010/tcp         -> 127.0.0.1:8302     nbb_darwin_godel_machines
8010/tcp         -> 127.0.0.1:8303     nbb_qualia_engine
8425/tcp         -> 127.0.0.1:8425     jarvis-autonomous-learner
9000/tcp         -> 127.0.0.1:9000     jarvis-69dgm-bridge
8006/tcp         -> 127.0.0.1:9006     psychological_rag_domain
10001/tcp        -> 127.0.0.1:10001    jarvis-dgm-bridge-01
10001/tcp        -> 127.0.0.1:10002    jarvis-dgm-bridge-02
10001/tcp        -> 127.0.0.1:10003    jarvis-dgm-bridge-03
10001/tcp        -> 127.0.0.1:10004    jarvis-dgm-bridge-04
10001/tcp        -> 127.0.0.1:10005    jarvis-dgm-bridge-05
10001/tcp        -> 127.0.0.1:10006    jarvis-dgm-bridge-06
10001/tcp        -> 127.0.0.1:10007    jarvis-dgm-bridge-07
10001/tcp        -> 127.0.0.1:10008    jarvis-dgm-bridge-08
10001/tcp        -> 127.0.0.1:10009    jarvis-dgm-bridge-09
10001/tcp        -> 127.0.0.1:10010    jarvis-dgm-bridge-10
10001/tcp        -> 127.0.0.1:10011    jarvis-dgm-bridge-11
10001/tcp        -> 127.0.0.1:10012    jarvis-dgm-bridge-12
10001/tcp        -> 127.0.0.1:10013    jarvis-dgm-bridge-13
10001/tcp        -> 127.0.0.1:10014    jarvis-dgm-bridge-14
10001/tcp        -> 127.0.0.1:10015    jarvis-dgm-bridge-15
10001/tcp        -> 127.0.0.1:10016    jarvis-dgm-bridge-16
10001/tcp        -> 127.0.0.1:10017    jarvis-dgm-bridge-17
10001/tcp        -> 127.0.0.1:10018    jarvis-dgm-bridge-18
10001/tcp        -> 127.0.0.1:10019    jarvis-dgm-bridge-19
10001/tcp        -> 127.0.0.1:10020    jarvis-dgm-bridge-20
10001/tcp        -> 127.0.0.1:10021    jarvis-dgm-bridge-21
10001/tcp        -> 127.0.0.1:10022    jarvis-dgm-bridge-22
10001/tcp        -> 127.0.0.1:10023    jarvis-dgm-bridge-23
11434/tcp        -> 127.0.0.1:11434    jarvis-ollama
16686/tcp        -> 127.0.0.1:16686    jarvis-jaeger
7260/tcp         -> 127.0.0.1:17260    jarvis-brain-orchestrator
8081/tcp         -> 127.0.0.1:18091    jarvis-hilbert-gateway
8081/tcp         -> 127.0.0.1:18092    jarvis-hilbert-state
8092/tcp         -> 127.0.0.1:18093    jarvis-hilbert-time
```
</details>

---
*Source: `../04-evidence/facts.json` and `../04-evidence/snapshots/latest/`. Regenerate; do not edit by hand.*
