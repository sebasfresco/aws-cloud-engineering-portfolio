# Week 1 - First Principles Foundation

Week 1 is the reset.

Before building bigger architectures, I wanted to be able to explain the AWS services I’ve actually used in production, why I picked them, and what I’d pick instead if the constraints changed.

## Output
- [`aws-services-audit.md`](./aws-services-audit.md)

## Notes (handwritten)
- Core problem (Day 0): `notes/core-problem.pdf`
- Well-Architected takeaways (Days 3–4): `notes/well-architected-framework.pdf`
- Business value mapping: `notes/business-value-mapping.pdf`

## What I cared about this week
- Choosing services based on constraints, not habits
- Understanding the “real” trade-offs (cost, ops overhead, limits)
- Writing notes that a teammate could actually learn from

## Quick takeaways
- “Managed” almost always means you’re trading money for time and reliability.
- S3 is the default storage layer for a reason. Most tools assume it exists.
- The difference between a junior and a serious engineer is being able to explain why a service is wrong.

## Next
Week 2 moves into networking and security boundaries (VPC, subnets, routing, SGs/NACLs) and stress-testing failure modes on purpose.
