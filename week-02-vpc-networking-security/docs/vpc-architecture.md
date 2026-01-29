# VPC Architecture Decision Document

This document captures the reasoning behind a production-style VPC build: public/private subnets, explicit routing, and layered security.

The goal was not complexity.
The goal was something clean, realistic, and easy to explain.

---

## 1) Goal

Design a foundational AWS network that supports real production patterns:

- public + private subnet separation
- inbound internet access only where it belongs
- outbound-only internet access for private workloads
- clear routing paths (no guessing)
- layered security (Security Groups + NACLs)
- room to expand into ALB → app → database tiers

---

## 2) Options Considered

### Option A: Single Subnet (Flat Network)

**Why it is tempting**
- fast
- minimal setup

**Why I rejected it**
- no segmentation
- higher blast radius
- not production-aligned

**Status:** Rejected

---

### Option B: Public + Private Subnets (No NAT)

**Pros**
- clean separation
- private tier stays fully isolated

**Cons**
Private instances cannot do normal operations like:
- OS updates
- package installs
- external API calls

**Status:** Rejected

---

### Option C: Public + Private Subnets + NAT Gateway (Chosen)

**Pros**
- production-style segmentation
- private tier stays non-public
- private workloads can still reach the internet outbound

**Cons**
- NAT Gateway adds recurring cost
- routing must be correct or the private tier breaks immediately

**Status:** Selected

---

## 3) Final Design

### Public subnet
- default route: `0.0.0.0/0 → Internet Gateway (IGW)`
- used for internet-facing components (bastion / ALB tier patterns)

### Private subnet
- default route: `0.0.0.0/0 → NAT Gateway`
- used for internal workloads (app/db tiers)

### Supporting components
- Internet Gateway (IGW)
- NAT Gateway
- separate route tables (public vs private)
- Security Groups (stateful, instance-level)
- Network ACLs (stateless, subnet-level)

This is the baseline VPC layout you will see across most real AWS environments.

---

## 4) Trade-offs

### Security vs simplicity
Two subnets plus NAT adds moving parts.
In exchange, you get real boundaries and clearer blast radius control.

### Cost vs operational overhead
A NAT Gateway costs more than running a NAT instance.
But it is managed, reliable, and does not turn networking into a server maintenance problem.

### Flexibility vs restriction
Private subnets do not accept inbound internet traffic.
That restriction is the point.
It forces better architecture patterns instead of accidental exposure.

---

## 5) Cost Notes (Approx.)

| Component | Approx. Monthly Cost | Notes |
|----------|----------------------|-------|
| NAT Gateway | ~$33 | plus data processing / egress |
| EC2 t3.micro (public) | ~$8 | bastion / public workload |
| EC2 t3.micro (private) | ~$8 | internal tier placeholder |
| IGW, route tables, NACLs | $0 | no direct cost |
| NAT data transfer | variable | charged per GB |

NAT Gateway is the main cost center here.
It is a managed service, and AWS charges a premium for convenience.

---

## 6) Failure Testing

### Test: remove NAT Gateway route from the private subnet
**Expected:** private instances lose outbound internet access

**Observed behavior**
- OS updates and package installs fail
- outbound calls to external APIs fail
- the instance can still communicate inside the VPC, but it cannot reach the public internet

**Reason**
Security Groups do not fix routing.
If the private route table does not have a valid path out, traffic dies inside the VPC.

---

## 7) Lessons Learned

- Routing is everything. Security Groups will not save you from wrong route tables.
- SGs and NACLs are not redundant. They do different jobs:
  - SGs = stateful, instance-level control
  - NACLs = stateless, subnet-level guardrails 
- When rules conflict, NACL denial wins at the subnet boundary. The instance never receives the traffic, even if the SG allows it.
- The cost of private networking shows up fast (NAT + data transfer).
- Production-grade cloud networking is mostly about intentionality.
