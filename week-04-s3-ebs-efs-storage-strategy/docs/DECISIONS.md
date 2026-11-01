# Storage Strategy -- Decision Document

## Problem

10 TB of data with mixed access patterns, stored at a flat S3 Standard tier regardless of access frequency. 2 TB of archival data accessed less than once per year sits at $0.023/GB-mo. That is significant overspend on cold data that does not require immediate retrieval.

**Scope:** the client is fictional, and controls are mapped to NIST 800-53. A defense contractor holding controlled unclassified information (CUI) is normally assessed against NIST SP 800-171 and CMMC, and data like "intelligence products" would raise the question of AWS GovCloud (US) instead of commercial us-east-1. This design does not answer either question.

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

### 3. Encryption: SSE-KMS with S3 Bucket Keys on data buckets, SSE-S3 on access-logs

Satisfies NIST 800-53 SC-28 (protection of information at rest). SSE-KMS on active-data and archive-data supports key rotation and provides an audit trail via CloudTrail for KMS key use.

S3 Bucket Keys are enabled on both. Without them, every PUT and GET calls KMS: 2.5M requests a month is $7.50 in KMS request charges. With them, S3 uses a bucket-level key and AWS says KMS request costs drop by up to 99 percent.

The access-logs bucket uses SSE-S3. S3 server access logging requires the destination bucket to use SSE-S3; with SSE-KMS default encryption, logs can be delivered encrypted with a key you cannot access. SSE-S3 is still AES-256 encryption at rest, so SC-28 is met for that bucket too.

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
| active-data | KMS: $1/key + 2.5M requests at $0.03/10K, cut ~99% by Bucket Keys | ~$1.10 |
| active-data | Requests (500K PUT / 2M GET) | ~$3.50 |
| archive-data | Glacier Deep Archive + KMS | ~$3.53 |
| access-logs | Mixed lifecycle | ~$3.00 |
| **Total proposed** | | **$173.74** |
| **Baseline (all Standard)** | | **$235.52** |
| **Annual savings** | | **~$741** |

---

## Compliance Mapping

| Control | Implementation |
| --- | --- |
| SC-28 Protection of Information at Rest | SSE-KMS on active-data and archive-data, SSE-S3 on access-logs |
| AC-3 Access Enforcement | Public access blocked at bucket and account level |
| SI-12 Information Management and Retention | Object Lock (Compliance mode) enforces 7-year retention on archive-data; versioning protects active-data from accidental overwrite |
| AU-2 Event Logging | CloudTrail logging active for all S3 and KMS events |
| AU-11 Audit Record Retention | access-logs lifecycle keeps records for the organization's defined retention period before expiry. The expiry must be set to meet that period, or this becomes a finding |

---

## What Breaks If You Change It

**Remove Object Lock:** Lose 7-year retention guarantee. Fail SI-12 (and the regulatory retention requirement). Data can be deleted before retention period expires.

**Move archive to Standard-IA instead of Glacier Deep Archive:** about 12.6x cost increase ($0.0125 vs $0.00099 per GB-mo) for data accessed less than once per year. No functional benefit. Moving it to Standard would be about 23x.

**Remove lifecycle policies on active-data:** All 8 TB stays at Standard pricing indefinitely. ~$26/mo wasted (2,458 GB x ($0.023 - $0.0125)) on data that is no longer actively accessed.

**Disable versioning:** Accidental deletions and overwrites become permanent. No recovery path without backups.

**Use SSE-S3 instead of SSE-KMS on the data buckets:** Lose CloudTrail audit trail for encryption events. Lose key rotation control. May fail SC-28 audit depending on assessor interpretation.

**Shorten 90-day lifecycle threshold:** Risk IA retrieval fees during active project phase. Validate with S3 Analytics first.

**Switch access-logs to SSE-KMS:** S3 server access log delivery breaks or produces logs you cannot read.

**Turn off S3 Bucket Keys:** KMS request charges rise from about $0.08 to about $7.50 a month at 2.5M requests.
