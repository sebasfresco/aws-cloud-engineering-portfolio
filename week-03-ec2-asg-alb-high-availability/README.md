# Week 3 - EC2 + Auto Scaling + ALB (High Availability)

Week 3 was about building a web tier that stays up when instances fail.

Instead of “one EC2 server behind a public IP,” this is the smallest production-style pattern you see everywhere in AWS:

**ALB → Target Group → Auto Scaling Group**  
across **two Availability Zones**, with health checks deciding what counts as “healthy.”

## Output (Clean Docs)
- Runbook: [`docs/alb-asg-runbook.md`](./docs/alb-asg-runbook.md)
- Cost analysis: [`docs/cost-analysis.md`](./docs/cost-analysis.md)
- Diagram: [`infra/asg-alb-architecture-diagram.png`](./infra/asg-alb-architecture-diagram.png)
- User data: [`scripts/userdata.sh`](./scripts/userdata.sh)

## Notes (Raw Working Material)
If you want the scratchpad thinking and receipts, they’re here:
- [`notes/`](./notes)

Includes:
- ALB + ASG notes
- EC2 instance type analysis
- failure modes and recovery behavior
- first principles breakdowns
- cost report (PDF)

## What I built
- Launch Template (`t3.micro`) bootstrapped with user data
- Target Group health checks (`HTTP GET /`)
- Auto Scaling Group (min 2, desired 2, max 4)
- Application Load Balancer routing traffic only to healthy instances

## What I tested
- terminating an instance and watching ASG recover automatically
- breaking the app (`httpd` down) and watching ALB cut it out
- how fast bad health checks can cause a full outage (503 + churn loops)
- the difference between “EC2 is running” and “the service is healthy”

## Cost reality
Even with tiny instances, high availability is not free.

At small scale, the ALB is usually the biggest fixed cost.
That’s the trade: you pay for controlled failure and clean recovery.

## Why it matters
A load balancer is not just traffic distribution.

It keeps users away from broken instances while the fleet heals itself.  
That’s the difference between deploying a server and running a service.
