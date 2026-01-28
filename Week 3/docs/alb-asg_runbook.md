# ALB + ASG Web Tier Runbook

## Purpose
Deploy and operate a highly available EC2 web tier using Application Load Balancer and Auto Scaling.

---

## Build Order

1. **VPC** (10.0.0.0/24) + Internet Gateway
2. **Public subnets** (2 AZs) with `0.0.0.0/0 → IGW` route
3. **Security Groups:**
   - ALB-SG: inbound HTTP from internet
   - Instance-SG: inbound HTTP from ALB-SG only
4. **Launch Template** (t3.micro, user data installs httpd)
5. **Target Group** (HTTP :80, health check: `GET / → 200`)
6. **Auto Scaling Group** (min=2, desired=2, max=4)
   - Attach to Target Group
   - Enable ELB health checks
7. **Application Load Balancer** (internet-facing, forward to Target Group)

**Critical:** Build in this order. ALB and ASG are useless without Target Group.

---

## Verification

- [ ] ALB DNS returns HTTP 200
- [ ] Page shows instance ID (refreshing alternates IDs)
- [ ] Target Group shows 2 Healthy targets
- [ ] Stop httpd on one instance → target becomes Unhealthy, ALB stops routing, ASG replaces

---

## Common Failures

### Instance dies
ASG replaces (2-3 min recovery)

### App crashes (httpd down)
- Target → Unhealthy
- ALB stops routing immediately  
- ASG terminates and replaces
- If Launch Template also broken → **churn loop**

### Bad health check path
All targets Unhealthy, 503 to users, ASG churn loop

### SG misconfigured
Targets stay Unhealthy despite app running
- **Fix:** Instance-SG must allow HTTP from ALB-SG (not IP)

### Missing IGW route
ALB unreachable from internet

---

## Rollback

### Bad deployment
1. Fix Launch Template user data
2. Start Instance Refresh (min healthy: 100%)

### Bad health check
1. Revert Target Group path to `/`
2. Wait for targets to stabilize

---

## Teardown Order

1. ASG (set desired=0, then delete)
2. Target Group
3. ALB
4. Launch Template
5. Security Groups
6. Subnets → IGW → VPC

Reverse of build order. Always.

---

## Cost

~$33/month (2× t3.micro + ALB)

**What doubles cost:** Running 2 instances for HA  
**Optimization:** Reserved Instances (~30-40% savings, 1-3 year commit)

---

## Key Insights

- **EC2 health ≠ ALB health** — ASG only acts on app health if ELB checks enabled
- **Target Group defines correctness** — health checks are contracts
- **ALB protects users immediately** — routing stops before ASG replaces

---

**This is production-valid for:**
- Internal tools
- Low-traffic apps  
- Dev/staging environments

**Next evolution:** Private subnets + NAT