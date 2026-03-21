# Week 1 -- First Principles Foundation

> **What this proves:** Can evaluate AWS services on constraints (cost, ops overhead, hard limits), not habit or familiarity.

Before building bigger architectures, I wanted to be able to explain the AWS services I've actually used in production, why I picked them, and what I'd pick instead if the constraints changed.

## Output

- Service audit: [`docs/aws-services-audit.md`](./docs/aws-services-audit.md)

## Handwritten notes

- Core problem: [`notes/core-problem.pdf`](./notes/core-problem.pdf)
- Well-Architected takeaways: [`notes/well-architected-framework.pdf`](./notes/well-architected-framework.pdf)
- Business value mapping: [`notes/business-value-mapping.pdf`](./notes/business-value-mapping.pdf)

(These are raw scans. Links are intentional even if GitHub preview doesn't render them.)

## Focus

- Service selection based on constraints: cost, ops burden, hard limits
- Understanding the real trade-offs, not definitions
- Writing notes a teammate could actually learn from

## Key decisions

- "Managed" almost always means trading money for time and reliability.
- S3 is the default storage layer for a reason. Most tools assume it exists.
- The difference between a junior and a serious engineer is being able to explain why a service is wrong for a given use case.

No architecture diagram for this week. This was a decision-making exercise, not a build.
