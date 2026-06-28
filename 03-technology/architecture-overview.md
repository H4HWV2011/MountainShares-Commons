# Architecture Overview

Ms. Allis (ALLIS — Artificial Learning & Location Intelligence System) is a
self-hosted community AI for rural Appalachia. It is built to *know its place* — to
reason about West Virginia's geography, history, governance, and resources with its
beliefs bound to specific locations and times — and to do so as a **glass-box**: every
belief and decision is inspectable, contestable, and traceable to evidence, including
the decisions of its own safety layers.

This page explains the architecture in plain terms. Live counts (containers, ports,
vector totals, database sizes) are **not** stated here — they live in the generated
evidence pages so they can never drift out of sync with the running system:
[`data-stores.md`](data-stores.md) and [`port-map.md`](port-map.md). For the formal
treatment, see the thesis in the [work repo](../90-provenance.md).

> **Naming.** "Ms. Allis" / "ALLIS" is the public name. The live services use the
> internal prefix `jarvis-` (e.g. `jarvis-chroma`, `jarvis-main-brain`). That prefix is
> the engine-room namespace, not a second product.

## Two bodies: semantic ⊗ spatial

The system is organized around two coupled "Hilbert bodies":

- **H_App — the semantic body.** A vector store (**ChromaDB**) holding the system's
  knowledge as embeddings: documents, beliefs, conversation memory, domain corpora.
  This is *what the system knows*.
- **H_geo — the spatial body.** A geospatial database (**PostgreSQL / PostGIS**) holding
  West Virginia's parcels, addresses, census geometry, building footprints, and the
  GBIM belief geometry. This is *where things are*.

The two are joined by a **tensor-product bridge** (written **H_App ⊗ H_geo**): a query
is resolved through a semantic arm and a spatial arm at once, so an answer about, say,
flood risk or food assistance is grounded both in what the corpus says and in the actual
geography of the place being asked about. A dispatcher service routes queries across both
arms and combines the result. The practical effect: when someone asks "what can I do for
my community in Fayette County?", the answer names real places and real resources, not
generic civic advice.

## GBIM — knowledge bound to place and time

At the center is the **Geospatial Belief Information Model (GBIM)**: rather than storing
facts as free-floating text, the system stores *beliefs* that are each bound to a
**where** and a **when**, with confidence metadata. This is what lets the system reason
about Appalachia specifically and audit how its understanding changes over time. The GBIM
belief graph, the Appalachian policy/resource corpus, and a set of domain-specific
retrieval services (RAG) are the operational form of the system's mission to give
communities an AI that genuinely knows their geography and governance.

## The reasoning layer

User queries are answered by an **ensemble of language models** rather than a single
model, coordinated by an orchestration layer and a main reasoning service, drawing on the
retrieval services above for grounding. The design favors grounded, traceable answers
over fluent-but-unverifiable ones — a response should be reconstructable back to the
evidence that produced it.

## Safety and accountability, built in

Accountability is structural, not a disclaimer. Every request passes through a layered
constitutional stack before and after it reaches the reasoning layer:

1. **Perimeter (Caddy `forward_auth`).** Unauthenticated requests are rejected at the
   proxy with HTTP 401 *before* reaching any reasoning or safety service. Because it sits
   outside the container stack, no internal reconfiguration can remove it — the most
   upstream guardrail in the system.
2. **Blood-Brain Barrier (BBB).** A safety filter that runs on every request before it
   reaches the model ensemble, screening for harmful, manipulative, or survivor-unsafe
   content, with each gate decision logged to memory.
3. **Constitutional Guardian.** Enforces the system's constitutional principles on
   verdicts; cannot be overridden by a token class or a configuration change.
4. **Alignment and judges.** An alignment layer and a pipeline of independent "judges"
   (truth, consistency, alignment, ethics) evaluate outputs, with signing keys for
   verifiable provenance.
5. **Psychological-integrity safeguards.** Additional protections oriented to vulnerable
   users and survivor safety.

The same principle runs through the whole system: power is constrained by design, and the
constraints are themselves inspectable.

## How this maps to what's running

The live system is a self-hosted microservice stack on a single machine, reachable
publicly only through an authenticated Cloudflare tunnel. Rather than describe its scale
in prose that would slowly go stale, this repository measures it directly: the container
fleet, the published ports, and the exposure surface are in [`port-map.md`](port-map.md),
and the semantic and spatial stores — including where the live stores stand relative to
the full corpus — are in [`data-stores.md`](data-stores.md). Both regenerate from a
read-only audit, so what this repo claims about the system always matches what the system
actually is.

---
*Plain-language overview. Formal definitions (the world model, the tensor-product
operator, GBIM, the constitutional stack) are in the work-repo thesis; live figures are
in the generated evidence pages. This page is prose and is maintained by hand; the numbers
it points to are not.*
