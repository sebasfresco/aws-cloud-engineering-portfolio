# 12-Week AWS Cloud Engineer Blueprint

This repo is my 12-week AWS Cloud Engineer blueprint.
I’m documenting what I build, what breaks, and what I learned from it, with diagrams, runbooks, and cost/security trade-offs along the way.

## Start Here

If you want the quick tour:

- **Week 3: High Availability Web Tier (EC2 + ASG + ALB)**
  - Runbook: [`week-03-ec2-asg-alb-high-availability/docs/alb-asg-runbook.md`](week-03-ec2-asg-alb-high-availability/docs/alb-asg-runbook.md)
  - Diagram: [`week-03-ec2-asg-alb-high-availability/infra/asg-alb-architecture-diagram.png`](week-03-ec2-asg-alb-high-availability/infra/asg-alb-architecture-diagram.png)
  - Userdata: [`week-03-ec2-asg-alb-high-availability/scripts/userdata.sh`](week-03-ec2-asg-alb-high-availability/scripts/userdata.sh)

- **Week 2: Production VPC Build (Networking + Security Boundaries)**
  - LinkedIn article + video: [I Built a Production-Grade VPC From Scratch — Here’s What I Learned](https://www.linkedin.com/pulse/i-built-production-grade-vpc-from-scratch-heres-what-learned-fresco-gmome/)
  - Notes: [`week-02-vpc-networking-security/vpc-architecture.md`](week-02-vpc-networking-security/vpc-architecture.md)
  - Diagram: [`week-02-vpc-networking-security/vpc-architecture-diagram.png`](week-02-vpc-networking-security/vpc-architecture-diagram.png)

- **Week 1: First Principles (Service Selection + Trade-offs)**
  - Audit notes: [`week-01-first-principles-foundation/aws-services-audit.md`](week-01-first-principles-foundation/aws-services-audit.md)

---

## Progress

- [x] Week 1: First Principles Foundation  
- [x] Week 2: VPC Networking + Security  
- [x] Week 3: EC2 + Auto Scaling + ALB  
- [ ] Week 4: Storage Strategy (S3 / EBS / EFS)  
- [ ] Week 5: Terraform Fundamentals + Modules  
- [ ] Week 6: CI/CD (CodePipeline Automation)  
- [ ] Week 7: IAM Policies + Roles + Audit  
- [ ] Week 8: VPC Hardening + Encryption + Compliance  
- [ ] Week 9: Terraform 3-Tier Production Architecture  
- [ ] Week 10: Cost Optimization + Well-Architected Review  
- [ ] Week 11: Serverless API (Lambda + DynamoDB)  
- [ ] Week 12: AWS Organizations + Multi-Account Portfolio

---

## How This Repo Is Organized

Each week is its own deliverable:

- `docs/` → runbooks, notes, decision docs  
- `infra/` → diagrams and architecture artifacts  
- `scripts/` → automation helpers (ex: userdata)

---

## About Me

**Sebastião Fresco**  
Systems / NOC Engineer | AWS | Security-minded

**Certifications**
- AWS Certified Solutions Architect – Associate  
- CompTIA Cloud+  
- CompTIA Security+  
- ITIL® Foundation

---

## Why I’m Doing This

I’m building a portfolio that’s reviewable:
what I built, how it works, and why I made the decisions I made.
