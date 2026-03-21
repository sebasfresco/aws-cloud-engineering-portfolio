# AWS Cloud Engineering Portfolio

**Sebastiao Fresco** | Infrastructure Engineer
AWS Solutions Architect Associate | CompTIA Cloud+ | CompTIA Security+ | ITIL Foundation

Every project includes a decision document: what I built, what I considered instead, why I chose this, what breaks if you change it, what it costs.

---

## What Each Week Proves

| Week | Topic | What This Proves | Key Link |
| --- | --- | --- | --- |
| 1 | [First Principles](week-01-first-principles-foundation/) | Can evaluate services on constraints, not habit | [Service audit](week-01-first-principles-foundation/docs/aws-services-audit.md) |
| 2 | [VPC Networking](week-02-vpc-networking-security/) | Can design network boundaries with blast radius control | [Decision doc](week-02-vpc-networking-security/docs/vpc-architecture.md) |
| 3 | [EC2 + ASG + ALB](week-03-ec2-asg-alb-high-availability/) | Can build HA that self-heals and explain the cost | [Runbook](week-03-ec2-asg-alb-high-availability/docs/alb-asg-runbook.md) |
| 4 | [Storage Strategy](week-04-s3-ebs-efs-storage-strategy/) | Can pick the right storage tier and defend it with numbers | [Decision doc](week-04-s3-ebs-efs-storage-strategy/docs/DECISIONS.md) |
| 5 | [Terraform IaC](week-05-terraform-fundamentals-modules/) | Can codify infrastructure, eliminate drift, deploy in one command | [Decision doc](week-05-terraform-fundamentals-modules/docs/DECISIONS.md) |
| 6 | [Docker + Containers](week-06-docker-container-fundamentals/) | Can containerize a workload with multi-stage builds and image hardening | Planned |
| 7 | [EKS / Kubernetes](week-07-eks-kubernetes-core/) | Can deploy to EKS aligned with DoW DSOP and Platform One mandates | Planned |
| 8 | [Security + Compliance](week-08-security-services-compliance/) | Can implement the detective control quad and document for ATO | Planned |
| 9 | [CI/CD the DoW Way](week-09-cicd-dow-way-security-scanning/) | Can build CI/CD with automated security scanning and policy gates | Planned |
| 10 | [Production EKS 3-Tier](week-10-production-eks-3tier-architecture/) | Can design a production-grade 3-tier architecture on EKS | Planned |
| 11 | [Splunk + Observability + Ansible](week-11-splunk-observability-ansible/) | Can instrument monitoring, integrate SIEM, and automate STIG hardening | Planned |
| 12 | [Portfolio Polish](week-12-portfolio-polish-application-blitz/) | Can present cloud engineering work as a cohesive portfolio | Planned |

---

## LinkedIn Articles

- **Week 5:** [Terraform Deployed My Entire AWS Architecture Under 5 Minutes](https://www.linkedin.com/pulse/terraform-deployed-my-entire-aws-architecture-under-5-fresco-glife/)
- **Week 4:** [AWS Storage: How Access Patterns, Benchmarks, and Cost Should Drive Every Decision](https://www.linkedin.com/pulse/aws-storage-options-first-principles-guide-sebasti%C3%A3o-fresco-jrose/)
- **Week 3:** [What Happens When an EC2 Instance Fails in Production?](https://www.linkedin.com/pulse/what-happens-when-ec2-instance-fails-production-alb-auto-fresco-znj9e/)
- **Week 2:** [How Network Boundaries Actually Work in AWS](https://www.linkedin.com/pulse/i-built-production-grade-vpc-from-scratch-heres-what-learned-fresco-gmome/)

---

## Progress

- [x] Week 1: First Principles Foundation
- [x] Week 2: VPC Networking + Security
- [x] Week 3: EC2 + Auto Scaling + ALB
- [x] Week 4: Storage Strategy (S3 / EBS / EFS)
- [x] Week 5: Terraform Fundamentals + Modules
- [ ] Week 6: Docker + Container Fundamentals
- [ ] Week 7: EKS / Kubernetes Core
- [ ] Week 8: Security Services + Compliance
- [ ] Week 9: CI/CD the DoW Way + Security Scanning
- [ ] Week 10: Production EKS 3-Tier Architecture
- [ ] Week 11: Splunk + Observability + Ansible
- [ ] Week 12: Portfolio Polish + Application Blitz

---

Each week: `docs/` (decision docs, runbooks), `infra/` (diagrams, Terraform), `scripts/` (automation).
