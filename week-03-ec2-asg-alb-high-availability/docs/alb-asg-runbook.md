# ALB + ASG Web Tier Runbook

## Purpose
Deploy a highly available EC2 web tier using an Application Load Balancer (ALB) and an Auto Scaling Group (ASG).

This is the smallest setup that behaves like a real system:
- traffic only goes to healthy instances
- broken instances get replaced automatically
- capacity can scale out when demand spikes

---

## Architecture (High Level)
Internet → ALB → Target Group → EC2 instances (Auto Scaling Group)

Baseline behavior:
- always keep 2 instances running (high availability)
- scale out to 4 instances under load
- recover automatically from instance or app failures

---

## Prerequisites
You need:
- a VPC with 2 public subnets across 2 Availability Zones
- a route to the internet from those subnets (`0.0.0.0/0 → IGW`)
- a Launch Template that installs and starts a web server using user data

Optional:
- EC2 key pair (only if you want SSH access)

---

## Build Order (Follow This Exactly)

### 1) Networking
Create or reuse a VPC with:
- 2 public subnets across 2 AZs
- an Internet Gateway attached to the VPC
- a public route table associated to both subnets:
  - `0.0.0.0/0 → IGW`

If this is wrong, the load balancer will exist but nobody can reach it.

---

### 2) Security Groups (Keep It Tight)
Create two security groups.

**ALB-SG**
- inbound: HTTP 80 from `0.0.0.0/0`
- outbound: allow all

**Instance-SG**
- inbound: HTTP 80 from ALB-SG only
- outbound: allow all

Important:
Instances should not accept traffic directly from the public internet.
The ALB should be the only entry point.

---

### 3) Launch Template
Create a Launch Template with:
- Amazon Linux 2 (or equivalent)
- instance type: `t3.micro`
- security group: Instance-SG
- user data that:
  - installs httpd
  - starts the service
  - enables it on boot
  - writes a basic HTML page that prints the instance ID

That last step matters.
It proves the ALB is actually balancing across instances.

---

### 4) Target Group
Create a Target Group:
- target type: Instances
- protocol: HTTP
- port: 80

Health check:
- protocol: HTTP
- path: `/`
- success codes: `200`

The Target Group is where correctness lives.
If the health check is wrong, your app can be working and still look “down.”

---

### 5) Auto Scaling Group
Create an Auto Scaling Group:
- launch template: your Launch Template
- subnets: both public subnets
- capacity:
  - min: 2
  - desired: 2
  - max: 4

Attach it to the Target Group.

Health checks:
- enable ELB health checks (important)

Without ELB health checks, ASG only cares if the instance is “running.”
With ELB checks enabled, ASG can react to the app being broken.

---

### 6) Application Load Balancer
Create an Application Load Balancer:
- internet-facing
- subnets: both public subnets
- security group: ALB-SG

Listener:
- HTTP 80 → forward to Target Group

At this point, your web tier is live.

---

## Verification

### ALB checks
- open the ALB DNS name in a browser
- confirm HTTP 200 response

### Target Group checks
- confirm 2 targets are Healthy

### Load balancing proof
Refresh a few times:
- the instance ID should change occasionally

---

## Failure Tests (Do These On Purpose)

### Test 1: Instance failure (terminate one instance)
Action:
- terminate one EC2 instance in the ASG

Expected:
- Target Group marks it Unhealthy
- ALB stops routing to it
- ASG launches a replacement instance
- you return to 2 healthy instances

Typical recovery:
- 2 to 3 minutes

---

### Test 2: Application failure (stop httpd)
Action:
- stop httpd on one instance

Expected:
- Target Group marks it Unhealthy
- ALB stops routing quickly
- ASG replaces it only if ELB health checks are enabled

If ELB health checks are not enabled:
- the instance stays “healthy” in ASG
- traffic fails until you fix the app manually

---

### Test 3: Misconfigured health checks (break it fast)
Action:
- set health check path to something that returns 404

Expected:
- targets become Unhealthy
- ALB returns 503
- ASG can churn (replace instances endlessly)

This is one of the cleanest ways to accidentally create downtime.

---

### Test 4: Scale-out test (trigger ASG under load)
Goal:
Prove the scaling policy works and see the timing.

One simple approach:
- generate load (Apache Bench or similar)
- watch desired capacity increase from 2 → 3 → 4

What to document:
- how long scale-out took
- whether the ALB stayed stable while new instances launched

---

## Common Failures and Fixes

### ALB returns 503
Meaning:
- there are no healthy targets

Fix order:
1. check Target Group health
2. confirm instance is serving HTTP 200 on `/`
3. confirm Instance-SG allows HTTP from ALB-SG

---

### Targets stay Unhealthy but the app is running
Common causes:
- Instance-SG rule is wrong (allowed from IPs, not ALB-SG)
- wrong health check path
- user data did not install or start httpd

Fix:
- validate `httpd` is running
- validate `/` returns 200 on the instance
- validate SG reference, not CIDR guessing

---

### Churn loop (instances replaced repeatedly)
Common causes:
- broken user data
- wrong health checks
- wrong SG rules

Fix:
- launch a single instance with the same Launch Template
- confirm it becomes healthy before letting ASG manage a fleet

---

## Rollback

### Bad user data deployment
Goal:
fix the Launch Template without taking the whole tier down.

Steps:
1. update Launch Template with corrected user data
2. start an Instance Refresh
3. keep minimum healthy at 100% (or high enough to avoid downtime)
4. confirm healthy targets before proceeding

---

### Bad health check config
Steps:
1. revert health check path to `/`
2. wait for targets to become Healthy
3. confirm the ALB stops returning 503

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
At small scale, the ALB is often the cost driver.

Baseline:
- 2x `t3.micro` running 24/7
- 1x ALB running 24/7

Expect roughly ~$30–$40/month depending on usage.

---

## Why ALB (Not NLB / GWLB)
**ALB** is built for HTTP/HTTPS apps and gives you application-layer routing and health checks.

**NLB** is for raw TCP/UDP performance and lower-level networking use cases.

**GWLB** is for inserting security appliances into traffic flows.
That is a different problem entirely.

For a simple web tier, ALB is the right tool.
