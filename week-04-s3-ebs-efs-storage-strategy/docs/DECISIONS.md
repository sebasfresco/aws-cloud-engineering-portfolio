# Storage Strategy -- Decision Document

## Problem

10 TB of data with mixed access patterns, stored at a flat S3 Standard tier regardless of access frequency. 2 TB of archival data accessed less than once per year sits at $0.023/GB-mo. That is significant overspend on cold data that does not require immediate retrieval.

---

## Proposed Architecture

Three dedicated S3 buckets, each with a lifecycle policy matched to its workload.

| Bucket | Size | Storage Class | Purpose |
| --- | --- | --- | --- |
| active-data | 8 TB | Standard, transitions to Standard-IA after 90 days | Project files, reports, intelligence products |
| archive-data | 2 TB | Glacier Deep Archive | Historical records, completed project archives |
| access-logs | ~50 GB/mo | Standard, cascading to IA, Glacier, then expire | S3 server logs + CloudTrail audit trail |

---

## Design Decisions

### 1. Active data lifecycle: Standard to Standard-IA after 90 days

Defense project deliverables see the heaviest access in the first 90 days (review cycles, revisions, submissions). After that window, access drops sharply. The 90-day threshold aligns the transition to observed behavior, avoiding IA retrieval fees during the active phase.

Validate with S3 Analytics before production deployment.

### 2. Archive storage class: Glacier Deep Archive

At $0.00099/GB-mo, Glacier Deep Archive is the lowest-cost S3 storage tier. 12-48 hour bulk retrieval is acceptable for historical records accessed less than once per year. Cost is 95% less than Standard.

### 3. Encryption: SSE-KMS on all buckets

Satisfies NIST 800-53 SC-28 (protection of information at rest). Supports key rotation and provides a full audit trail via CloudTrail for every encryption and decryption event.

### 4. Object Lock on archive bucket: Compliance mode, 7-year retention

Compliance mode prevents deletion by any user, including the root account. This is a one-way door: once set, the retention period cannot be shortened. Governance mode is insufficient for regulatory retention requirements.

### 5. Versioning: enabled on active-data and archive-data

Protects against accidental deletion and overwrites. Old versions on active-data transition to IA after 30 days to contain versioning overhead costs.

### 6. Public access: blocked on all buckets

Mandatory for defense contractor environments. Enforced at the bucket and account level. No exceptions.

---

## Cost Comparison

| Bucket | Line Item | Monthly |
| --- | --- | --- |
| active-data | Standard: 5,734 GB x $0.023 | $131.88 |
| active-data | Standard-IA: 2,458 GB x $0.0125 | $30.73 |
| active-data | KMS (~$1/key + $0.03/10K req) | ~$5.00 |
| active-data | Requests (500K PUT / 2M GET) | ~$3.50 |
| archive-data | Glacier Deep Archive + KMS | ~$3.53 |
| access-logs | Mixed lifecycle | ~$3.00 |
| **Total proposed** | | **$177.64** |
| **Baseline (all Standard)** | | **$235.52** |
| **Annual savings** | | **~$695** |

---

## Compliance Mapping

| Control | Implementation |
| --- | --- |
| NIST SC-28 | Encryption at rest via SSE-KMS across all buckets |
| NIST AC-3 | Public access blocked at bucket and account level |
| NIST SI-12 | Versioning enabled to protect information integrity |
| NIST AU-2 | CloudTrail logging active for all S3 and KMS events |
| NIST AU-11 | Object Lock (Compliance mode) enforces 7-year retention |

---

## What Breaks If You Change It

**Remove Object Lock:** Lose 7-year retention guarantee. Fail NIST AU-11 audit. Data can be deleted before retention period expires.

**Move archive to Standard-IA instead of Glacier Deep Archive:** 23x cost increase for data accessed less than once per year. No functional benefit.

**Remove lifecycle policies on active-data:** All 8 TB stays at Standard pricing indefinitely. ~$30/mo wasted on data that is no longer actively accessed.

**Disable versioning:** Accidental deletions and overwrites become permanent. No recovery path without backups.

**Use SSE-S3 instead of SSE-KMS:** Lose CloudTrail audit trail for encryption events. Lose key rotation control. May fail SC-28 audit depending on assessor interpretation.

**Shorten 90-day lifecycle threshold:** Risk IA retrieval fees during active project phase. Validate with S3 Analytics first.
