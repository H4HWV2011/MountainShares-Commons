# How this repository is maintained

This is a forward-facing, audited repository. It trades completeness for trust.
Three rules hold it together.

## 1. Canonical numbers are regenerated, not edited
Every figure that describes the live system — container counts, vector totals,
database sizes, port maps, exposure lists — is produced by an audit script and
written to `04-evidence/`. No other document retypes these numbers; they cite the
snapshot. To update them, re-run the scripts and refresh `04-evidence/`. This is
the discipline that prevents the figure drift that accumulates in a hand-maintained
repo (where the same metric can appear with eight different values).

Regenerate the infrastructure snapshot:
```bash
cd 04-evidence/scripts
./msjarvis_audit_snapshot.sh
sudo ./msjarvis_port_audit.sh
./msjarvis_chroma_backup_verify.sh
# then refresh 04-evidence/INFRASTRUCTURE_SNAPSHOT.md sections 1–3 from the output
```

## 2. Only verified, stable material belongs here
If a document describes something not yet built, not yet counsel-reviewed, or still
changing, it stays in the work repo (`msjarvis-public-docs`) and is cross-linked, not
copied. This repo should never contain a claim the live system can't back.

## 3. One name
Public-facing name is **Ms. Allis** (ALLIS — Artificial Learning & Location
Intelligence System) everywhere. The internal service prefix `jarvis-` may appear in
evidence artifacts and scripts because it is the real infrastructure namespace; it is
not an alternate product name and should not be introduced into prose.
