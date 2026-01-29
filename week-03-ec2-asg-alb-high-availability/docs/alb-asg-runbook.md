# ALB + ASG Web Tier Runbook

## Purpose
Deploy and operate a highly available EC2 web tier using an Application Load Balancer (ALB) and an Auto Scaling Group (ASG).

This runbook focuses on the web tier only:
- ALB handles traffic routing and health-based failover
- ASG keeps the fleet healthy and replaces broken instances
- User data bootstraps the application at launch

---

## Architecture (High Level)
Internet → ALB → Target Group → EC2 instances (ASG across 2 AZs)

Design goals:
- minimum 2 instances running at all times
- automatic recovery from instance failure or application failure
- horizontal scaling under load (up to 4 instances)

---

## Prerequisites
- VPC with public subnets in 2 Availability Zones
- Route to internet from the public subnets (`0.0.0.0/0 → IGW`)
- An EC2 key pair (optional, only if you plan to SSH)
- Basic web server install via user data (Apache httpd)

---

## Build Order (Do Not Skip)

### 1) VPC + Internet Gateway
- Create VPC (example: 10.0.0.0/24)
- Attach an Internet Gateway (IGW)
- Create 2 public subnets in 2 AZs

Why this matters:
ALB needs subnets that can reach the internet and provide redundancy across AZs.

---

### 2) Route table for public subnets
- Public route table:
  - `0.0.0.0/0 → IGW`
- Associate this route table with both public subnets

Failure mode if incorrect:
ALB will launch but will not be reachable from the internet.

---

### 3) Security Groups (SGs)
Create two security groups. Keep it strict.

**ALB-SG**
- Inbound:
  - HTTP 80 from `0.0.0.0/0`
- Outbound:
  - allow all (default)

**Instance-SG**
- Inbound:
  - HTTP 80 from ALB-SG only
- Outbound:
  - allow all (default)

Important:
Do not allow HTTP from the internet directly to the instances.
Only the ALB should talk to the instances.

---

### 4) Launch Template (LT)
Create a Launch Template with:
- AMI: Amazon Linux 2 (or equivalent)
- instance type: `t3.micro`
- security group: Instance-SG
- user data: installs + starts the web server

User data should:
- install httpd
- start httpd
- enable on boot
- write a simple page that includes instance metadata (instance ID)

This proves traffic is actually load balanced.

---

### 5) Target Group
Create a Target Group:
- target type: Instances
- protocol: HTTP
- port: 80
- health check:
  - protocol: HTTP
  - path: `/`
  - success codes: `200`

What the Target Group is doing:
It defines what “healthy” means.
If your health check is wrong, everything looks broken even if the app is fine.

---

### 6) Auto Scaling Group (ASG)
Create an Auto Scaling Group:
- launch template: use the LT you created
- subnets: pick both public subnets (2 AZs)
- capacity:
  - min: 2
  - desired: 2
  - max: 4
- health checks:
  - use ELB health checks
- attach to:
  - the target group

Why ELB health checks matter:
EC2 can be “running” while the web app is dead.
ELB health checks let the ASG act on application health, not just instance status.

---

### 7) Application Load Balancer (ALB)
Create an Application Load Balancer:
- internet-facing
- subnets: both public subnets
- security group: ALB-SG
- listener: HTTP 80
- forward action: Target Group

At this point, your stack is live.

---

## Verification (What “Good” Looks Like)

### Load balancer checks
- ALB DNS name loads successfully in a browser
- response is HTTP 200

### Target group checks
- Target Group shows 2 Healthy instances

### HA behavior
Refresh the page multiple times:
- instance ID should alternate between instances (or at least change occasionally)

---

## Failure Tests (On Purpose)

### Test 1: Kill an instance
Action:
- terminate one EC2 instance in the ASG

Expected:
- Target Group marks it Unhealthy
- ALB stops routing to it
- ASG launches a replacement instance
- fleet returns to 2 healthy instances

Time expectation:
- 2 to 3 minutes for recovery

---

### Test 2: Break the app (httpd down)
Action:
- stop httpd on one instance

Expected:
- Target Group marks instance Unhealthy
- ALB stops routing to it quickly
- ASG replaces it only if ELB health checks are enabled

Common mistake:
If ELB health checks are not enabled, ASG will keep the instance because EC2 still looks “healthy.”

---

### Test 3: Bad health check path
Action:
- change health check path to a route that returns 404

Expected:
- all targets become Unhealthy
- ALB returns 503
- ASG may churn (terminate and replace repeatedly)

This is one of the fastest ways to accidentally take down a service.

---

## Common Failures and Fixes

### ALB returns 503
Most common reasons:
- Target Group has 0 healthy instances
- health check path is wrong
- instance security group blocks ALB

Fix:
- check Target Group health status first
- validate SG rule: Instance-SG must allow HTTP from ALB-SG

---

### Targets stay Unhealthy even though the app is running
Likely causes:
- wrong SG reference (allowed from IP instead of ALB-SG)
- health check path is wrong
- user data never installed the web server

Fix:
- confirm `httpd` is running on the instance
- confirm `/` returns 200 locally on the instance

---

### ALB unreachable from the internet
Likely causes:
- wrong subnet type (no IGW route)
- ALB in subnets that do not have public routing

Fix:
- confirm public route table includes `0.0.0.0/0 → IGW`
- confirm ALB subnets are associated with that route table

---

### Churn loop (instances constantly replaced)
Common causes:
- broken user data script
- health check fails on every boot
- bad target group settings

Fix:
- validate user data works on a single instance first
- keep health check path simple (`/`)
- review user data output logs on the instance

---

## Rollback Procedures

### Bad user data deployment
Goal:
Recover without taking the service fully down.

Steps:
1. Update Launch Template with corrected user data
2. Start an Instance Refresh
3. Set minimum healthy percentage to 100% (or high enough to avoid downtime)
4. Validate targets return Healthy before continuing

---

### Bad health check configuration
Steps:
1. Revert health check path to `/`
2. Wait for targets to return Healthy
3. Confirm ALB stops returning 503

---

## Teardown Order (Reverse Dependencies)

1. Auto Scaling Group (set desired=0, then delete)
2. Target Group
3. ALB
4. Launch Template
5. Security Groups
6. Subnets, IGW, VPC

---

## Cost Notes (Rough)
Baseline for this web tier:
- 2x t3.micro running 24/7
- 1x ALB running 24/7

Approx: ~$33/month (rough estimate)

What increases cost:
- scaling above 2 instances
- keeping high availability (2 instances minimum)
- higher traffic volumes through the ALB

Cost levers:
- Reserved Instances or Savings Plans for predictable compute
- Spot instances for non-critical environments (not recommended for a simple always-on web tier)

---

## Key Insights
- EC2 health does not equal application health
- Target Group health checks define “correctness”
- ALB protects users immediately by stopping routing to unhealthy instances
- ASG enforces availability by replacing instances to hit desired capacity

---

## Good Fit For
- internal tools
- low-traffic apps
- dev/staging environments
- lightweight web tier foundations

Next evolution:
- private subnets + NAT
- TLS (HTTPS) on the ALB
- Terraform modules for repeatable deployments
