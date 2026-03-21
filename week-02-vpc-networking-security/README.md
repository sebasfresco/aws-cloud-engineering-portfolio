# Week 2 -- VPC Networking + Security

> **What this proves:** Can design a production VPC with intentional segmentation, explicit routing, and layered security, and explain the cost of each choice.

Not "launch a VPC and move on."
I wanted to understand the design choices behind a production-style network, what each component is responsible for, and what actually breaks when something is missing.

## Quick demo (video)

LinkedIn article + video:
https://www.linkedin.com/pulse/i-built-production-grade-vpc-from-scratch-heres-what-learned-fresco-gmome/

## Output

- Decision doc: [`docs/vpc-architecture.md`](./docs/vpc-architecture.md)
- Architecture diagram: [`infra/vpc-architecture-diagram.png`](./infra/vpc-architecture-diagram.png)
- Question drills (handwritten): [`notes/question-drills.pdf`](./notes/question-drills.pdf)

## What I built

- VPC with a public subnet and a private subnet
- Internet Gateway for public subnet routing
- NAT Gateway for private subnet outbound access
- Separate route tables for public vs private tiers
- Security Groups and NACLs layered together

## Design constraints

- Subnet separation and blast radius control
- Routing as the real source of truth
- SG vs NACL differences in real behavior, not definitions
- NAT Gateway cost and why it exists (~$33/mo)
