# Week 1 - First Principles Foundation

This week was about building a base. Not memorizing AWS services, but being able to explain what they actually do, when they make sense, and when they’re a waste.

## What I did
I wrote down every AWS service I’ve used in production and forced myself to answer a simple question:

**What problem does this solve, and what’s the trade-off?**

## Main deliverable
- [`aws-services-audit.md`](./aws-services-audit.md)

## What this sets up
This is the foundation for everything in the rest of the 12-week blueprint:
- choosing compute without guessing (EC2 vs Lambda vs containers)
- choosing storage based on access patterns (S3 vs EBS vs EFS)
- understanding managed services as a time vs money trade
- being intentional about security boundaries (IAM + VPC)
- keeping cost in mind early instead of “figuring it out later”

## Takeaways
- Most services are simple when you strip away the branding. The confusion comes from options, not complexity.
- “Managed” usually means you’re paying AWS to handle the annoying parts.
- The real skill is being able to explain why you chose something, not just that you used it.
