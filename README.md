# 12-Week AWS Cloud Engineer Blueprint

This is my 12-week AWS Cloud Engineer blueprint, where I’m documenting what I build, break, and learn, with diagrams, runbooks, and real cost/security trade-offs.

## Start Here (Quick Tour)

If you only have 5 minutes, start with these:

- **Week 3 (Compute + High Availability):** EC2 + Auto Scaling + ALB  
  → Runbook: [`week-03-ec2-asg-alb-high-availability/docs/alb-asg-runbook.md`](week-03-ec2-asg-alb-high-availability/docs/alb-asg-runbook.md)  
  → Diagram: [`week-03-ec2-asg-alb-high-availability/infra/asg-alb-architecture-diagram.png`](week-03-ec2-asg-alb-high-availability/infra/asg-alb-architecture-diagram.png)  
  → Userdata Script: [`week-03-ec2-asg-alb-high-availability/scripts/userdata.sh`](week-03-ec2-asg-alb-high-availability/scripts/userdata.sh)

- **Week 2 (Networking + Security):** VPC architecture + decision-making  
  → LinkedIn article + video: [I Built a Production-Grade VPC From Scratch — Here’s What I Learned](https://www.linkedin.com/pulse/i-built-production-grade-vpc-from-scratch-heres-what-learned-fresco-gmome/)  
  → Notes: [`week-02-vpc-networking-security/vpc-architecture.md`](week-02-vpc-networking-security/vpc-architecture.md)  
  → Diagram: [`week-02-vpc-networking-security/vpc-architecture-diagram.png`](week-02-vpc-networking-security/vpc-architecture-diagram.png)

- **Week 1 (First Principles):** AWS services audit + fundamentals reset  
  → Notes: [`week-01-first-principles-foundation/aws-services-audit.md`](week-01-first-principles-foundation/aws-services-audit.md)

---

## Progress Tracker (Weeks 1–12)

- [x] **Week 1:** First Principles Foundation  
- [x] **Week 2:** VPC Networking + Security  
- [x] **Week 3:** EC2 + Auto Scaling + ALB (High Availability)  
- [ ] **Week 4:** S3 + EBS + EFS (Storage Strategy)  
- [ ] **Week 5:** Terraform Fundamentals + Modules  
- [ ] **Week 6:** CI/CD with CodePipeline (Automation)  
- [ ] **Week 7:** IAM Policies + Roles + Audit  
- [ ] **Week 8:** VPC Hardening + Encryption + Compliance  
- [ ] **Week 9:** Terraform 3-Tier Production Architecture  
- [ ] **Week 10:** Cost Optimization + Well-Architected Review  
- [ ] **Week 11:** Serverless API (Lambda + DynamoDB)  
- [ ] **Week 12:** AWS Organizations + Multi-Account Portfolio

---

## Repo Structure

Each week is organized as a standalone mini-deliverable:

- `docs/` → runbooks, decision docs, notes  
- `infra/` → architecture diagrams and infrastructure artifacts  
- `scripts/` → deployment helpers and automation (ex: userdata)

---

## What This Blueprint Focuses On

I’m building this using a three-pillar approach:

1. **Technical Excellence**  
   Hands-on AWS builds with real failure-testing and validation.

2. **Engineering Leadership**  
   Documentation, runbooks, and clear trade-off reasoning (cost, security, reliability).

3. **First Principles Thinking**  
   Understanding *why* the architecture exists, not just copying tutorials.

---

## About Me

**Sebastiao Fresco**  
Systems / NOC Engineer | AWS | Security-minded

**Certifications**
- AWS Certified Solutions Architect – Associate  
- CompTIA Cloud+
- CompTIA Security+  
- ITIL® Foundation    

---

## Notes

This repo is intentionally documentation-first.  
The goal is to make the reasoning reviewable: what I built, how it works, and why it was the right call.
