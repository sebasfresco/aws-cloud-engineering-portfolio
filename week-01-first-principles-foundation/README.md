# Week 1 - First Principles Foundation

## Objective
Reset my thinking from “sysadmin who knows tools” to “cloud engineer who understands why things exist.”
This week is about fundamentals, trade-offs, and getting honest about what I’ve actually used in production.

## Deliverable
- AWS Services Audit (First Principles Notes):  
  [`aws-services-audit.md`](./aws-services-audit.md)

## What I focused on
I wrote down every AWS service I’ve used in real environments and explained it in plain English first, then used the correct technical terms where it matters.

The point wasn’t to list services. The point was to be able to answer questions like:
- What problem does this service solve?
- What’s the trade-off?
- When is it the wrong tool?

## 3 Takeaways (in plain English)
1) **Most AWS services exist to save you time, not to be fancy.**  
   “Managed” usually means you pay more money so you don’t have to babysit it.

2) **S3 is the default for a reason.**  
   It’s cheap, durable, works with everything, and most tools assume you have it.

3) **The real skill is choosing the right tool, not knowing 100 tools.**  
   The difference between junior and mid-level is being able to explain why you picked something and what you gave up.

## Notes
This is the foundation for the rest of the 12-week blueprint because every project later on depends on these basics:
- compute choices (EC2 vs Lambda vs containers)
- storage choices (S3 vs EBS vs EFS)
- security boundaries (IAM + VPC)
- cost awareness (what runs 24/7 vs what’s event-driven)
