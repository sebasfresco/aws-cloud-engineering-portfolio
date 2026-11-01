# Week 3 -- EC2 + Auto Scaling + ALB (High Availability)

> **What this proves:** Can build a self-healing web tier across two AZs and explain what high availability actually costs. A load balancer keeps users away from broken instances while the fleet heals itself. That is the difference between deploying a server and running a service.

**ALB, Target Group, Auto Scaling Group** across **two Availability Zones**, with health checks deciding what counts as "healthy."

## Quick demo (video)

LinkedIn article + video:
https://www.linkedin.com/pulse/what-happens-when-ec2-instance-fails-production-alb-auto-fresco-znj9e/

## Output

- Runbook: [`docs/alb-asg-runbook.md`](./docs/alb-asg-runbook.md)
- Cost analysis: [`docs/cost-analysis.md`](./docs/cost-analysis.md)
- Diagram: [`infra/asg-alb-architecture-diagram.png`](./infra/asg-alb-architecture-diagram.png)
- User data: [`scripts/userdata.sh`](./scripts/userdata.sh)

## Notes

- [`notes/`](./notes)

## What I built

- Launch Template (`t3.micro`) bootstrapped with user data
- Target Group health checks (`HTTP GET /`)
- Auto Scaling Group (min 2, desired 2, max 4)
- Application Load Balancer routing traffic only to healthy instances

## Failure tests

- **Instance termination:** ASG replaced in ~2-3 min, ALB rerouted within health check interval
- **App failure (httpd down):** ALB cut traffic to broken instance, ASG replaced it (only with ELB health checks enabled)
- **Bad health check path (404):** All targets marked unhealthy and the ASG entered a churn loop replacing instances endlessly. I saw 503s. The ALB fails open when every target is unhealthy, so the 503s most likely came from moments when churn left no targets registered, not from the health check failing itself
- **Scale-out under load:** Desired capacity increased from 2 to 4, ALB stayed stable while new instances launched

## Cost reality

Even with tiny instances, high availability is not free.

At small scale, the ALB is usually the biggest fixed cost: about $22/month with light traffic, plus about $7.30 for its two public IPv4 addresses. The whole stack runs about $45-52/month 24/7 (see [`docs/cost-analysis.md`](./docs/cost-analysis.md)).
That is the trade: you pay for controlled failure and clean recovery.
