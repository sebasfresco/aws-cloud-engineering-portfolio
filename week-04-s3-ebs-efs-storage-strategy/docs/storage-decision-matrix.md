# AWS Storage Decision Matrix

us-east-1 list prices, first pricing tier. This table replaces the React component I first built (`storage-decision-matrix.tsx`), which GitHub could not render. [`decision_matrix.png`](./decision_matrix.png) is the original January 2026 image. The rows marked † changed since then; see [Corrections](#corrections-since-the-original-image).

## Overview

| Criteria | S3 Standard | S3-IA | S3 Glacier Deep Archive | EBS gp3 | EBS io2 | EFS | FSx Lustre |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Type | Object | Object | Object | Block | Block | File (NFS) | File (Lustre) |
| Access pattern | HTTP API, any client | HTTP API, infrequent | Bulk retrieval, rare | Single EC2 only | Single EC2 only | Multi-EC2 concurrent | Multi-EC2 (HPC) |
| Max size † | Unlimited | Unlimited | Unlimited | 64 TiB | 64 TiB | Unlimited | Unlimited |

## Reliability

| Criteria | S3 Standard | S3-IA | S3 Glacier Deep Archive | EBS gp3 | EBS io2 | EFS | FSx Lustre |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Durability | 99.999999999% | 99.999999999% | 99.999999999% | 99.8-99.9% | 99.999% | 99.999999999% | N/A (scratch) |
| Availability | 99.99% | 99.9% | N/A | 99.999% | 99.999% | 99.99% | ~99.9% |

## Cost

| Criteria | S3 Standard | S3-IA | S3 Glacier Deep Archive | EBS gp3 | EBS io2 | EFS | FSx Lustre |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Cost / GB-mo | $0.023 | $0.0125 | $0.00099 | $0.08 | $0.125 | $0.30 | $0.14 |
| Cost / TB / year † | ~$283 | ~$154 | ~$12 | ~$984 | ~$1,536 | ~$3,686 | ~$1,720 |
| Retrieval fee † | None | $0.01/GB | $0.02/GB standard (12 h), ~$0.0025/GB bulk (48 h) | N/A | N/A | N/A | N/A |

Cost per TB per year is cost per GB-month x 1,024 x 12. EBS io2 and gp3 also charge for provisioned IOPS and throughput above the baseline, which is not included here.

## Performance

| Criteria | S3 Standard | S3-IA | S3 Glacier Deep Archive | EBS gp3 | EBS io2 | EFS (Elastic) | FSx Lustre |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Max IOPS † | N/A | N/A | N/A | 80,000 (3,000 baseline) | 256,000 | 900K-2.5M read, 500K write per file system | Millions |
| Max throughput † | N/A | N/A | N/A | 2,000 MiB/s (125 MiB/s baseline) | 4,000 MB/s | 20-60 GiB/s read, 1-5 GiB/s write per file system; 1,500 MiB/s per client | 1+ TB/s |

### Lab benchmarks (fio on a t3.micro, us-east-1, January 2026)

| Test | EBS gp3 | EFS | Winner |
| --- | --- | --- | --- |
| Sequential write (MB/s) | 139 | 109 | gp3 |
| Sequential read (MB/s) | 136 | 302 | EFS |
| Random 4K read IOPS | 7,017 | 4,704 | gp3 |
| Random 4K write IOPS | 7,076 | 4,727 | gp3 |
| Average latency (usec) | 677 | 3,472 | gp3 |

† gp3 won on random IOPS, latency and sequential write. EFS won only on sequential read. Treat the gp3 numbers with caution: a gp3 volume's baseline is 3,000 IOPS and 125 MiB/s, and these results are above both. That usually means fio measured the OS page cache (run without `--direct=1`) unless the volume was provisioned above baseline. Results from a t3.micro are not representative of larger instance types.

## Capabilities

| Criteria | S3 Standard | S3-IA | S3 Glacier Deep Archive | EBS gp3 | EBS io2 | EFS | FSx Lustre |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Multi-instance | Yes | Yes | Yes | No | Limited (Multi-Attach) | Yes | Yes |
| POSIX filesystem | No | No | No | Yes | Yes | Yes | Yes |

## Decision guide

| Service | Use when | Don't use when |
| --- | --- | --- |
| S3 Standard | Static assets, active data lakes, frequent access | Need filesystem mount or low-latency block ops |
| S3-IA | Backups, DR copies, data accessed <1x/month | Data accessed frequently; retrieval fees negate savings |
| S3 Glacier Deep Archive | Compliance archives, data accessed <1x/year | Need data in under 12 hours |
| EBS gp3 | Boot volumes, databases, default block storage | Need shared access across multiple EC2 instances |
| EBS io2 | High-IOPS databases (Oracle, SQL Server, SAP HANA) | Cost-sensitive; gp3 handles most workloads |
| EFS | Shared config, CMS media, ASG web servers | Need raw, consistent IOPS; single-instance workloads |
| FSx Lustre | ML training, HPC, genomics, video processing | Standard web apps; overkill unless HPC |

## Corrections since the original image

| Row | Image says | Now | Why |
| --- | --- | --- | --- |
| gp3 max size | 16 TiB | 64 TiB | AWS raised gp3 limits; EBS user guide |
| gp3 max IOPS | 16,000 | 80,000 | Same |
| gp3 max throughput | 1,000 MB/s | 2,000 MiB/s | Same |
| S3-IA cost / TB / year | ~$170 | ~$154 | Arithmetic: $0.0125 x 1,024 x 12 |
| S3 Standard cost / TB / year | ~$284 | ~$283 | Arithmetic: $0.023 x 1,024 x 12 |
| Deep Archive retrieval | $0.02/GB (bulk) | $0.02 is the standard tier; bulk is ~$0.0025 | Retrieval tiers |
| EFS max throughput | ~1 GB/s (elastic) | 20-60 GiB/s read per file system | EFS performance docs |
| EFS max IOPS | ~500K | 500K is the write figure; reads go to 900K-2.5M | Same |
| Benchmark footnote | EFS outperformed gp3 on random IOPS; EBS and EFS share the same network pipe | gp3 won random IOPS; claim about a shared pipe removed | The footnote contradicted the table. Nitro instances have dedicated EBS bandwidth |
