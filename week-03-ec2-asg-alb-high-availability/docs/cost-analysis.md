# Cost Analysis - Auto Scaling Web Tier (Week 3)

## Summary
This week’s build is a minimal, highly available web tier:

- Application Load Balancer (ALB)
- EC2 Auto Scaling Group (ASG)
- 2 Availability Zones
- `t3.micro` instances

Two cost realities show up immediately:
1. high availability starts at 2 instances
2. at small scale, the load balancer can cost more than compute

---

## Architecture Snapshot
Auto Scaling Group:
- min: 2
- desired: 2
- max: 4 (scale out on CPU > 40%)

ALB:
- internet-facing
- forwards to Target Group
- health check: `GET /`

Region assumption:
- us-east-1

---

## Pricing Assumptions
| Service | Price |
|------|------|
| EC2 `t3.micro` | $0.0104 / hour |
| ALB | $0.0225 / hour |
| ALB LCU (light traffic) | ~ $0.008 / hour |
| Month | 730 hours |

Traffic assumption:
- low LCU usage

---

## Scenario A: Always On (24/7)

### EC2 (2 instances)
2 × $0.0104/hr × 730 hrs  
= **$15.18 / month**

### ALB (hours + low LCU)
ALB hours: $0.0225 × 730 = **$16.43**  
LCU: $0.008 × 730 = **$5.84**  
ALB total = **$22.27 / month**

### Total
| Component | Monthly Cost |
|---|---:|
| EC2 (2× t3.micro) | $15.18 |
| ALB + LCU | $22.27 |
| **Total** | **$37.45** |

---

## Scenario B: Business Hours Compute (ALB still on)
Assumptions:
- compute runs ~10 hrs/day, 22 days/month (~220 hrs)
- ALB stays online (common reality)

### EC2 (2 instances for 220 hrs)
2 × $0.0104/hr × 220 hrs  
= **$4.58 / month**

### ALB (still always on)
ALB hours: $0.0225 × 730 = **$16.43**  
LCU reduced estimate: ~$0.004 × 730 = **$2.92**  
ALB total = **$19.35 / month**

### Total
| Component | Monthly Cost |
|---|---:|
| EC2 | $4.58 |
| ALB + LCU | $19.35 |
| **Total** | **$23.93** |

---

## Cost Comparison
| Scenario | Monthly Cost |
|---|---:|
| 24/7 always on | $37.45 |
| business-hours compute | $23.93 |
| **savings** | **~$13.50 (36%)** |

---

## What “High Availability” Actually Costs
The cost increase comes from paying for redundancy:

- 2 instances minimum (not 1)
- load balancer running continuously
- extra headroom for failure, not for performance

High availability is resilience you buy upfront.

---

## Optimization Levers

### Reserved Instances / Savings Plans
Good for predictable usage.
Savings: ~30–40% on EC2

Trade-off:
- commitment (1 or 3 years)
- less flexibility if your architecture changes

### Spot Instances (partial use)
Savings: up to ~70–80% on EC2

Trade-off:
- interruptions
- only safe for stateless workloads

### Scheduled scaling
Works when traffic patterns are predictable.

Trade-off:
- not useful for true 24/7 services
- can reduce availability if you scale too aggressively

---

## Conclusion
This is close to the cheapest version of “real” high availability on AWS.

At small scale:
- compute stays cheap
- the ALB is the big fixed cost

The bigger takeaway is the point of the build:
you should be able to explain why the architecture costs what it costs, and what you get in return.
