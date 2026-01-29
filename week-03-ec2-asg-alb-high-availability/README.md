# Week 3 - EC2 + Auto Scaling + ALB (High Availability)

Week 3 was about building a real web tier that stays up even when instances fail.

This is the smallest “production-valid” pattern I know:
an ALB in front of an Auto Scaling Group across two AZs, with health checks acting as the gatekeeper.

## Output
- Runbook: [`docs/alb-asg-runbook.md`](./docs/alb-asg-runbook.md)
- Diagram: [`infra/W3 Diagram.png`](./infra/W3%20Diagram.png)
- User data: [`scripts/userdata.sh`](./scripts/userdata.sh)

## What I built
- EC2 Launch Template bootstrapped by user data
- Target Group with health checks
- Auto Scaling Group (min 2, max 4)
- Application Load Balancer routing traffic only to healthy instances

## What I tested
- instance termination and recovery
- application failure behavior (health checks)
- common misconfigurations that cause 503s and churn loops

## Why this matters
This is where AWS stops feeling like “servers in the cloud” and starts feeling like an actual system.

A load balancer is not just traffic distribution.
It is how you keep users away from broken instances while the fleet heals itself.
