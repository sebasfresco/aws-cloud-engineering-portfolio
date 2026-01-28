# Week 2 - VPC Networking + Security

Week 2 was all about AWS networking and security boundaries.

Not “launch a VPC and move on.”
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

## What I focused on
- Subnet separation and blast radius control
- Routing as the real “source of truth”
- SG vs NACL differences in real behavior, not definitions
- NAT Gateway cost and why it exists

## Notes I kept for myself
The question drills are short but they helped a lot:
- why AWS separates Security Groups and NACLs
- why you cannot delete a VPC with resources inside it
- why NAT Gateway cost shows up fast in real builds
