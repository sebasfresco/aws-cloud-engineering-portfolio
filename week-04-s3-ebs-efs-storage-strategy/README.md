# Week 4 -- Storage Strategy (S3 / EBS / EFS)

> **What this proves:** Can select storage tiers based on access patterns and compliance requirements, and quantify the savings.

## Quick demo (video)

LinkedIn article + video:
https://www.linkedin.com/pulse/aws-storage-options-first-principles-guide-sebasti%C3%A3o-fresco-jrose/

## Output

- Decision doc: [`docs/DECISIONS.md`](./docs/DECISIONS.md)
- Decision matrix: [`docs/storage-decision-matrix.md`](./docs/storage-decision-matrix.md) (corrected figures)
- Original matrix image, January 2026: [`docs/decision_matrix.png`](./docs/decision_matrix.png). Some figures in it are out of date or wrong; the markdown version lists what changed
- Strategy document (HTML): [`docs/storage-strategy.html`](./docs/storage-strategy.html)
- Architecture sketch: [`infra/scenario.jpg`](./infra/scenario.jpg)

## What I built

A three-bucket tiered S3 architecture for a 10 TB environment with mixed access patterns:

| Bucket | Size | Storage Class | Purpose |
| --- | --- | --- | --- |
| active-data | 8 TB | Standard, transitions to IA at day 91 | Project files, reports, intelligence products |
| archive-data | 2 TB | Glacier Deep Archive | Historical records, completed project archives |
| access-logs | ~50 GB/mo | Standard, cascading to IA, Glacier, then expire | S3 server logs + CloudTrail audit trail |

active-data and archive-data use SSE-KMS with S3 Bucket Keys; access-logs uses SSE-S3, which S3 server access logging requires. Versioning is on for the data buckets, and public access is blocked at bucket and account level. Archive bucket uses Object Lock (Compliance mode) for 7-year retention.

## Design constraints

- 10 TB total, 80% active (monthly access), 20% archival (<1x/year)
- 7-year retention requirement (regulatory)
- NIST 800-53 controls (SC-28, AC-3, SI-12, AU-2, AU-11). See the scope note in the decision doc on 800-171, CMMC and GovCloud
- Cost reduction without sacrificing availability for active data

## Cost reality

| Metric | Value |
| --- | --- |
| Proposed (tiered) | $173.74/mo |
| Baseline (all Standard) | $235.52/mo |
| Annual savings | ~$741 (26% reduction at 10 TB) |
| At 100 TB | ~$7,400/yr savings |
| At 1 PB | ~$74,000/yr savings |

The savings compound. Lifecycle policies are a one-time configuration. The cost reduction is permanent and scales linearly with data growth.

## Notes

- [`notes/first_principles.pdf`](./notes/first_principles.pdf)
- [`notes/s3_cost_deep_dive.pdf`](./notes/s3_cost_deep_dive.pdf)
- [`notes/storage_decision_matrix.pdf`](./notes/storage_decision_matrix.pdf)
