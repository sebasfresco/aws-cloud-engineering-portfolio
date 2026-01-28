# Week 2 - VPC Networking + Security

This week was about building a production-style VPC from scratch and understanding what actually controls traffic in AWS.

I built the full layout (public/private subnets, IGW, NAT, route tables), layered SGs + NACLs, and broke parts of it on purpose to see what fails and why.

## Quick demo (video)
LinkedIn article + video:  
[I Built a Production-Grade VPC From Scratch — Here’s What I Learned](https://www.linkedin.com/pulse/i-built-production-grade-vpc-from-scratch-heres-what-learned-fresco-gmome/)

## Output
- Decision doc: [`vpc-architecture.md`](./vpc-architecture.md)
- Diagram: [`vpc-architecture-diagram.png`](./vpc-architecture-diagram.png)
- Question drills: [`question-drills.pdf`](./notes/question-drills.pdf)

## What I built
- VPC with public + private subnets
- Internet Gateway (public routing)
- NAT Gateway (private outbound)
- Separate route tables (public vs private)
- Security Groups + NACLs (layered)

## Key decisions
- Public/private split for clean boundaries and reduced blast radius
- NAT Gateway for outbound access without exposing private resources
- Route tables treated as the “source of truth” for traffic flow
- SGs for instance-level control, NACLs for subnet guardrails
