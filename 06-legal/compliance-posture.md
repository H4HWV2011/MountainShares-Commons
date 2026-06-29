# Compliance Posture

This page states MountainShares' current regulatory posture across the four areas
where it touches law: securities, money services, nonprofit/tax, and public benefits.
It is written to be read by counsel and reviewers. It is a factual summary of posture,
**not legal advice**, and the governing documents are the Program Rules, Phase
Specifications, Terms and Conditions, and DAO Governance Charter — not this page.

> **Status.** The MountainShares program documents are **drafts for board, counsel, and
> community review prior to Phase 0 activation.** Several positions below are explicitly
> under active review by qualified counsel and are not settled. This page does not
> represent that any review is complete.

## The honest one-paragraph version

MountainShares is a closed-loop community mutual-credit and prepaid-value program. It is
deliberately structured so that the regulated activities sit in the right boxes: the
charitable nonprofit (H4H) sponsors and operates the program but is **not** the money
transmitter; at launch the spendable currency (M$) operates as **closed-loop stored value,
exempt from money-transmitter licensing under WV Code §32A-2-3(c)**, with the DUNA standing
as the money-services framework for any later open-loop or cash-out step; and the founder's
commercial engine (KTS) holds founder-side economics entirely outside the charity and
outside community credits. Where the law is genuinely unsettled — most importantly the
securities treatment of the earned-credit system — the program states that it is under
counsel review and **makes no representation either way**, rather than self-certifying.

## The four pressure points

| Area | Current posture | Who holds it | Review status |
|---|---|---|---|
| **Securities** | EMS and M$ are community instruments, not shares, stock, partnership units, or ownership interests. The program makes **no representation** as to whether EMS or M$ is or is not a security. | DUNA / program | **Under review by securities counsel** |
| **Money services** | **At launch: closed-loop stored value, exempt under WV Code §32A-2-3(c)** — M$ redeemable only for goods/services in-network, cash-out disabled by default. Beyond closed-loop, the DUNA is the money-services licensee framework. **H4H is not the money transmitter.** | MountainShares DAO/DUNA | Closed-loop exemption applies at launch; DUNA licensing is the path for any open-loop/cash-out step |
| **Nonprofit / tax** | H4H is a verified 501(c)(3) public charity operating under IRS rules; the three-box wall keeps founder value out of charitable assets and community credits. | Harmony for Hope, Inc. | IRS status verified; ongoing nonprofit compliance |
| **Public benefits** | Benefits-Sensitive Account (BSA) safeguards protect participants whose public benefits could be affected by participation. | H4H / DUNA | **Under benefits-counsel review; no Private Letter Ruling obtained** |

## Securities posture, in full

EMS (Earned MountainShares) and M$ (Purchased MountainShares) are instruments used
**inside** the MountainShares Commons. Per the Terms and Conditions, MountainShares is
**not** a bank account, a deposit account, a savings product, an equity program, or a
promise of profit. EMS and M$ are **not** shares, stock, partnership units, or ownership
interests in H4H, the DUNA, KTS, or any other entity, and community EMS holders receive
no equity, ownership, or profit-participation rights.

The program does **not** assert that EMS or M$ is a non-security. The
**securities-law treatment of EMS, M$, and the phase-based conversion mechanism is under
review by securities counsel, and the program makes no representation as to whether any of
them is or is not a security.** Phase-based buying-power schedules are conditional,
revocable, reserve-gated, and non-vested — no participant holds a vested or guaranteed
right to a future conversion rate before a reserve threshold is cleared. Any *appreciating*
founder-side instrument exists exclusively on the **KTS side**, under separate,
counsel-reviewed documentation, and never through H4H charitable assets or community EMS.

No participant should treat EMS or M$ as a speculative asset or financial investment.

## Money-services posture, in full

**At launch, M$ operates as closed-loop stored value under West Virginia gift-card law.**
West Virginia Code §32A-2-3(c) exempts "the issuance and sale of closed loop stored value
cards or similar prepaid products which are intended to purchase items only from the issuer
or seller" from the state money-transmitter article. M$ is structured to fit that
exemption: it is loaded with USD and **redeemable only for goods and services inside the
MountainShares network**, not generally accepted outside it and not broadly cashed out.
Consistent with the closed-loop model, fiat cash-out is **disabled by default** (see the
benefits-sensitive protections below). The launch posture is therefore a gift-card /
closed-loop stored-value program, not money transmission.

**Beyond closed-loop, the DUNA is the money-services framework.** Any future step that
would move M$ outside the closed-loop exemption — general acceptance beyond the network,
broad fiat cash-out, or open-loop transfer — is money transmission under WV Code §32A-2-1,
and is built to run through the **MountainShares DAO/DUNA as money-services licensee of
record** (WV Money Transmitter License, FinCEN MSB registration, surety bond, BSA/AML
program). **H4H is not the money transmitter** in either posture.

Two honest caveats, confirmed with counsel rather than assumed: a multi-merchant community
network sits near the boundary between "closed-loop" and "semi-closed" stored value, so the
exemption's application to MountainShares specifically is a counsel determination, not a
self-judgment; and the federal FinCEN Prepaid Access Rule treats closed-loop products as
exempt only under per-product load limits, which the program parameters are set to respect.

## Nonprofit / tax posture

Harmony for Hope, Inc. is a verified 501(c)(3) public charity (EIN 81-1907024; IRS
determination letter dated and effective March 21, 2017; Publication 78 listed; PC
deductibility). Verification documents are in
[`../04-evidence/primary-sources/`](../04-evidence/primary-sources/), and the entity
detail is in [`entity-structure.md`](entity-structure.md). H4H operates MountainShares as
a charitable, community-benefit program within IRS nonprofit rules. The three-box wall is
audited **in operation, not only on paper** — any mechanism that would let founder value be
realized through charitable assets or community EMS is treated as a Critical structural
finding requiring immediate resolution.

## Public-benefits posture

Many participants receive public benefits whose eligibility could be affected by income or
asset changes. MountainShares includes **Benefits-Sensitive Account (BSA)** safeguards
designed to protect those participants, and benefits status is handled with privacy
protection (the relevant status field defaults to "prefer not to say"). Benefits and tax
consequences of participation are **under benefits-counsel review, and no
MountainShares-specific Private Letter Ruling has been obtained.** Participants are
responsible for obtaining independent advice about the legal, tax, and benefits
consequences specific to their circumstances; the program does not provide individualized
legal, tax, or benefits advice.

## How posture is enforced, not just stated

Compliance here is meant to be verifiable, not promised. The program's design includes
daily reserve monitoring (Operational Reserve Ratio and Treasury Reserve Solvency Ratio),
a documented audit cadence across financial, technical, and governance domains, and
**hard safety triggers that no governance vote can override** — including automatic
reversion to prior-phase parameters if a reserve threshold is not maintained. The intent
is that the three-box separation and the safety bands are demonstrable in the running
system and its audit trail, not merely asserted in documents.

## Open items, stated plainly

- **KTS** holds federal **EIN 42-3329393** (single-member WV LLC, assigned June 23, 2026);
  the **WV Secretary of State Certificate of Organization is pending.** Founder-side IP
  assignment and capital instruments are executable subject to any separate documents
  counsel requires and to state formation completing.
- **DUNA money-services licensing** is contingent on counsel and regulator confirmation.
- **Securities treatment** of EMS, M$, and the conversion mechanism is under counsel review.
- **No Private Letter Ruling** has been obtained on benefits/tax treatment.
- The program documents are **drafts pending counsel and board approval before Phase 0.**

## Where to go next

- Verified entity facts and the three-box structure → [`entity-structure.md`](entity-structure.md)
- IRS primary sources → [`../04-evidence/primary-sources/`](../04-evidence/primary-sources/)
- Program mechanics, reserves, and phases → [`../02-program/`](../02-program/)

---
*Factual summary of compliance posture as of the program's pre–Phase 0 review stage. Not
legal advice; not the governing documentation. Where this page and the governing documents
or counsel guidance differ, those govern.*
