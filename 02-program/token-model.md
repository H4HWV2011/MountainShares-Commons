# Token Model

MountainShares has two kinds of value, and keeping them distinct is the key to
understanding the whole system. One is a stable spend unit. The other is recognition of
contribution that can — under strict, reserve-gated conditions — grow in buying power
over time.

> **Read this first.** Nothing on this page is a present right to money, an investment,
> or a guarantee. The buying-power schedule described below is **conditional, reserve-
> gated, revocable, and not vested.** No participant holds a vested or guaranteed right to
> any future rate. Securities-law treatment is under review by securities counsel, which
> makes no representation either way.

## The two value layers

| | **PMS / M$** (Purchased) | **EMS** (Earned) |
|---|---|---|
| What it is | The spendable network unit | Recognition of community contribution |
| How you get it | Load USD through an approved channel | Earn it for documented contribution (caregiving, mutual aid, education, cultural work, mapping, governance, connectivity stewardship) |
| Value | **1 M$ = $1**, stable | A recognition record that can convert to spendable M$ under rules |
| Behavior | Spendable in-network immediately, subject to fees, caps, and reserve checks | Starts as recognition in an unlimited ledger; only part converts to M$, under caps and reserve gates |

**M$ is the stable unit.** Loading "$100" results in a **100 M$** balance. Fees are shown
on top of the load, never silently skimmed from the value you intended to load. M$ stays
pegged at $1 throughout every phase — it does not inflate or appreciate. It is the
dependable thing you spend.

**EMS is the thing that can appreciate.** It is first a record of who contributed and
how. Part of it can be converted into spendable M$, and the *buying power* assigned to an
EMS unit can step upward as the community treasury grows strong enough to support it
safely — see the appreciation schedule below.

## The appreciation schedule (conditional)

The buying power of an EMS unit expands by phase, and **only** when the treasury clears the
required solvency threshold. Until a threshold is cleared, EMS holds its baseline value.

| Phase | EMS buying power | Unlocks when | If the threshold is lost |
|---|---|---|---|
| **Phase 1 (baseline)** | 1 EMS ≈ $1 of in-network buying power | Default | — |
| **Phase 2** | 1 EMS ≈ $10 of in-network buying power | Treasury Reserve Solvency Ratio **≥ 300%** + formation costs paid | Auto-reverts to Phase 1 ($1) |
| **Phase 3** | 1 EMS ≈ the **Volunteer Time Value Rate** (FVSR) in effect at activation | Treasury Reserve Solvency Ratio **≥ 500%** + prior-phase costs paid | Below 500% → reverts to Phase 2 ($10); below 300% → reverts to Phase 1 ($1) |

Three things matter about this schedule:

- **It is buying power, not guaranteed cash.** "1 EMS ≈ $10" means an EMS converts to about
  10 M$ of in-network spending power when a participant *elects* to convert — not a
  promise of $10 cash. Conversion is user-initiated, optional, and incremental; the
  treasury pays only for EMS that participants actively choose to convert.
- **It reverts automatically.** If the treasury falls below a threshold, the higher rate
  switches off on its own. No governance vote can override a reversion. This is what keeps
  the system solvent: the high rates simply do not exist unless the reserves to back them
  do.
- **The Phase 3 rate is externally set, not invented.** It is the **Independent Sector /
  Do Good Institute Value of Volunteer Time** (a BLS-derived figure, **not** a federal or
  IRS rate), in effect on the date Phase 3 activates. The 2026 figure is **$36.14**. The
  DAO does not vote on this number; it is published externally and surfaced on the
  dashboard each year.

## The two reserve ratios

The system's safety rests on two continuously monitored metrics:

- **Operational Reserve Ratio** = treasury reserve ÷ total outstanding spendable M$. Governs
  day-to-day spending safety, earning caps, and which commerce features are unlocked.
- **Treasury Reserve Solvency Ratio** = treasury reserve ÷ (total outstanding EMS + M$).
  Governs the EMS buying-power schedule and phase progression — it is the primary
  conversion gate.

One answers *"can the system safely handle current spending?"* The other answers *"is the
treasury strong enough to support a higher recognition-to-buying-power rate without becoming
unsound?"* Both are calculated daily and published.

## How the treasury grows: fees

Every transaction type contributes to operations and reserve growth at once. The governing
*Parameter Tables* set exact values; the structure is:

| Fee | Rate | Purpose |
|---|---|---|
| Load fee | 2.85% of fiat load | Operations + treasury + platform + connectivity |
| Internal transfer fee | 0.25% | 100% to Treasury Reserve |
| Merchant fee | 1.80% | Primary treasury-building mechanism as commerce scales |
| ATM / refund fee | $1.25 flat | Treasury Reserve |
| Supplemental treasury assessment | +0.55% of volume | Treasury Reserve (compounding) |

Collected fee revenue is split on a fixed allocation:

| Share | To |
|---|---|
| 30% | Harmony for Hope, Inc. — nonprofit operations, compliance, program delivery |
| 30% | Treasury Reserve — backing reserve and phase-threshold growth |
| 15% | Platform Development — The Commons app and Ms. Allis infrastructure |
| 15% | Community Connectivity — Operations (free public internet, never paywalled) |
| 10% | Community Connectivity — Infrastructure (free public internet, never paywalled) |

The Treasury Reserve and H4H Operations shares each have a **floor (20%)** that cannot be
reduced without a 66% super-majority DAO vote, board ratification, and 30 days' notice. The
two connectivity buckets (25% combined) fund free public internet that is permanently
available and never behind a paywall.

## What this model is — and is not

It is a closed-loop, reserve-backed community mutual-credit and prepaid-value system
designed so that value circulates locally and recognition of real community labor can,
over time and only when safe, become meaningful local buying power. It is **not** a bank
account, a deposit, a savings product, an equity stake, a profit share, or a speculative
asset. EMS and M$ confer no ownership in H4H, the DUNA, or KTS.

See [`phases/`](phases/) for how the phases unlock, [`governance-charter.md`](governance-charter.md)
for who controls the adjustable parameters, and
[`../06-legal/compliance-posture.md`](../06-legal/compliance-posture.md) for the regulatory
posture.

---
*Illustrative of the model as reconciled in the governing documents. Exact band values,
caps, and rates are set by the Program Rules – Parameter Tables and Phase Specifications,
which control. Not investment, tax, or legal advice.*
