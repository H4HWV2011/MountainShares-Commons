# Phases 0–3

MountainShares grows in phases. Each phase adds capacity, but **only** when the community
treasury is strong enough to support it safely. Phases are not a timeline you advance
through by waiting — they are unlocked by hard reserve thresholds, and they revert
automatically if those thresholds are lost. Exact band values are in the governing
*Phase Specifications* and *Parameter Tables*; this is the shape.

## The gating logic

Two reserve metrics control everything (see [`../token-model.md`](../token-model.md)):

- **Operational Reserve Ratio** — spending-safety and commerce features.
- **Treasury Reserve Solvency Ratio** — the EMS buying-power schedule and phase progression.

A phase's higher rates are **conditionally active**: live only while the threshold holds,
and switched off automatically the moment it doesn't. No governance vote can override a
reversion.

## The phases

### Phase 0 — Invite-only beta
A bounded, invite-only proving stage. EMS earned here carries forward permanently at the
**baseline** value and counts toward voting eligibility, role eligibility, and rank — but
it carries **no appreciation right and no conversion-to-fiat right**. Founding participation
is recognized and locked.

### Phase 1 — Launch and safety
The default operating phase. Priorities are bounded growth, strong safety controls,
benefits-sensitive protections, and transparent reserve monitoring. EMS converts to
spendable M$ at the **baseline rate (≈ $1 of buying power per EMS)**. This is the floor the
system always reverts to if higher phases lose their thresholds.

### Phase 2 — Regional growth
Unlocks when the **Treasury Reserve Solvency Ratio reaches ≥ 300%** and formation costs are
paid. EMS buying-power expansion becomes **conditionally active at ≈ $10 per EMS**, higher
earning caps open, and more commerce features unlock — all within reserve bands the DAO can
adjust only inside safety limits. If the ratio falls below 300%, the system **reverts
automatically to Phase 1**.

### Phase 3 — Surplus distribution
Unlocks when the **Treasury Reserve Solvency Ratio reaches ≥ 500%** (sustained) and
prior-phase costs are paid. EMS buying-power advances to the **Volunteer Time Value Rate**
(the Independent Sector / Do Good Institute value, BLS-derived, **not** a federal or IRS
rate; 2026 figure $36.14) in effect at activation, and a community surplus-distribution
("dividend") mechanism becomes operational under the strictest governance thresholds. If
the ratio falls below 500% → **revert to Phase 2**; below 300% → **revert to Phase 1**.

## The reversion cascade, plainly

| If Treasury Reserve Solvency Ratio… | Then |
|---|---|
| stays ≥ 500% | Phase 3 rates active |
| falls below 500% | auto-revert to Phase 2 (≈ $10), no vote |
| falls below 300% | auto-revert to Phase 1 (≈ $1), no vote |

**Reversion is not a failure — it is the safety system working.** The design guarantees the
system can only ever offer a higher rate when the reserves to honor it actually exist. If
they don't, EMS simply holds its baseline value, and the community keeps operating safely.
This is why the model is sound even if Phase 3 never activates: the high rates are a
conditional reward for a strong treasury, never a liability the treasury can't cover.

---
*Shape of the phased rollout as reconciled in the governing documents. Exact thresholds,
bands, caps, and rates are set by the Phase Specifications and Parameter Tables, which
control. Nothing here is a vested right or a guarantee.*
