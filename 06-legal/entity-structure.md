# Entity Structure

This page states the legal entities behind MountainShares and Ms. Allis, and how they
are separated. Facts about Harmony for Hope, Inc. are verified against the IRS Tax
Exempt Organization Search and the IRS determination letter, both held as primary
sources in [`../04-evidence/primary-sources/`](../04-evidence/primary-sources/). Where
this page and other documents disagree, the IRS records govern.

## Harmony for Hope, Inc. (H4H) — verified

| Field | Value | Source |
|---|---|---|
| Legal name | Harmony for Hope Inc. | IRS TEOS |
| EIN | **81-1907024** | IRS TEOS |
| Other name on file | Harmony for Hope – Southern WV Community and Youth Band | IRS TEOS |
| Tax status | 501(c)(3) public charity | IRS determination letter |
| Determination letter | Favorable, dated **March 21, 2017** | `FinalLetter_81-1907024_HARMONYFORHOPEINC_03212017.tif` |
| Publication 78 listing | **Yes** — contributions are tax-deductible | IRS TEOS |
| Deductibility code | **PC** (public charity) | IRS TEOS |
| Address of record | **706 Main Street, Mount Hope, WV 25880** | IRS TEOS (mailing + principal officer) |
| Principal officer | Carrie Ann Kidd | IRS TEOS (most recent filing) |
| Annual filing | Form 990-N (e-Postcard); filed each year 2017–2025; not terminated | IRS TEOS |
| Website | https://www.harmonyforhopewv.org/ | IRS TEOS |

Donors may rely on the Publication 78 listing in determining the deductibility of
their contributions to H4H.

> **Address note.** The IRS record of record is **706 Main Street**. The operational
> server node for Ms. Allis / ALLIS is at **704 Main Street** (Fayette County Community
> Arts Center). The building spans 704–708 Main Street. Throughout this repository,
> **706 Main Street** is used for legal, tax, and funder-facing references that must
> match the federal record; **704 Main Street** is used only where the operational node
> is specifically meant.

> **Determination date.** The favorable letter is dated March 21, 2017. The ruling's
> *effective* date is stated within the letter itself; cite that letter for the effective
> date rather than the filename date if the two differ.

## The three-box structure

H4H is one of three entities, deliberately separated so that charitable, community, and
founder interests cannot bleed into one another. Full mechanics are in
[`../02-program/`](../02-program/); the legal summary:

| Entity | Legal form | Role | Key constraint |
|---|---|---|---|
| **Harmony for Hope, Inc.** | 501(c)(3) public charity (verified) | Charitable anchor; program sponsor and legal operator; treasury fiduciary | Operates under IRS nonprofit rules; cannot be a path to founder equity; **is not the money transmitter** |
| **MountainShares Commons / DUNA** | Decentralized Unincorporated Nonprofit Association | Community ledger, EMS/M$ system, DAO governance; **money-services licensee of record** | Holds the WV Money Transmitter License, FinCEN MSB registration, surety bond, and BSA/AML program; community EMS confers no equity or ownership |
| **Kidd's Technical Services (KTS)** | WV single-member LLC — **EIN assigned, state formation pending** | Founder commercial engine; holder of the Ms. Allis / ALLIS platform IP | Federal **EIN 42-3329393** assigned June 23, 2026; sole member Carrie A. Kidd. The WV Secretary of State Certificate of Organization is **pending**; until it issues, KTS is EIN-assigned but not a completed WV LLC |

## Kidd's Technical Services (KTS) — verified

| Field | Value | Source |
|---|---|---|
| Legal name | KIDDS TECHNICAL SERVICES | IRS CP575G |
| EIN | **42-3329393** (assigned June 23, 2026) | IRS CP575G |
| Legal structure | Single-Member Limited Liability Company | IRS EIN assignment |
| Sole member / responsible party | Carrie A. Kidd | IRS CP575G |
| County / state | Fayette County, WV | IRS EIN assignment |
| Address of record | 706 Main Street, Mount Hope, WV 25880 | IRS CP575G |
| Principal activity | Service — geospatial | IRS EIN assignment |
| Operating under trade name since | June 2024 | IRS EIN assignment (LLC start date) |
| **WV Secretary of State formation** | **Certificate of Organization pending** | — |

KTS has operated under the trade name since June 2024 and now holds a federal EIN, but
the WV LLC is **not legally formed until the Secretary of State Certificate of
Organization is filed and accepted.** Until then, KTS is accurately described as
**EIN-assigned, WV formation pending** — not "unformed," and not "formed." The
publishable EIN notice (CP575G) is in
[`../04-evidence/primary-sources/`](../04-evidence/primary-sources/); the EIN-application
summary is held privately because it contains personally identifying information.

## Reconciling the 990-N filing scale

H4H files the **Form 990-N (e-Postcard)** as a small organization with **gross receipts
not greater than $50,000**. That filing accurately reflects H4H's own charitable
operations. It is consistent — by design — with the larger financial flows described in
the MountainShares program materials, because those flows do **not** run through H4H:

- The **fee revenue, treasury reserves, and cash-out rails** sit with the
  **MountainShares DAO/DUNA** as money-services licensee of record, not with H4H.
- The **founder capital contribution** (documented senior technical work) is a **KTS-side**
  instrument, recorded outside H4H charitable assets and outside community EMS. KTS now
  holds a federal EIN; founder-side instruments are executable subject to any separate
  documents counsel requires, and to WV LLC formation completing.

In short: H4H's 990-N reflects a small charitable nonprofit; the money-services and
founder-side economics live in separate boxes by deliberate legal-structural design.
This separation is the point of the three-box structure, and it is what keeps the
charitable, community, and founder layers from contaminating one another.

## Status and open items (stated plainly)

- **KTS** holds federal **EIN 42-3329393** (single-member LLC, assigned June 23, 2026); the
  **WV Secretary of State Certificate of Organization is pending.** Founder-side IP
  assignment and capital instruments are executable subject to any separate documents
  counsel requires and to state formation completing.
- **DUNA money-services licensing** is contingent on counsel confirming that a license is
  required and that the WV Division of Financial Institutions will license the DUNA
  directly; otherwise a DUNA-controlled licensed entity substitutes.
- **Securities-law treatment** of EMS, M$, and the phase-based conversion mechanism is
  **under review by securities counsel**. This repository makes no representation as to
  whether any of them is or is not a security.
- **Benefits treatment** associated with MountainShares participation is under
  benefits-counsel review; **no MountainShares-specific Private Letter Ruling has been
  obtained.**

---
*Primary sources for H4H's status are in [`../04-evidence/primary-sources/`](../04-evidence/primary-sources/):
the IRS Tax Exempt Organization Search detail and the IRS determination letter. This page
is a factual summary, not legal advice, and not the governing program documentation.*
