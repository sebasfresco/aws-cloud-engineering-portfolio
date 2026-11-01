# AWS Cloud Engineering Portfolio

**Sebastiao Fresco** | Infrastructure Engineer | AWS Solutions Architect Associate | CompTIA Cloud+ | CompTIA Security+ | ITIL Foundation

Weeks 2, 4, 5 and 6 each have a decision document: what I built, what I considered instead, why I chose it, and what it costs. Week 1 is a service audit and Week 3 is a runbook with failure tests.

**Status: finished.** The program was scoped for 12 weeks. I chose to end it after Week 6. Next are the CKA and the AWS Certified Solutions Architect - Professional.

---

## What Each Week Proves

| Week | Topic | What This Proves | Key Link |
| --- | --- | --- | --- |
| 1 | [First Principles](week-01-first-principles-foundation/) | Can evaluate services on constraints, not habit | [Service audit](week-01-first-principles-foundation/docs/aws-services-audit.md) |
| 2 | [VPC Networking](week-02-vpc-networking-security/) | Can design network boundaries with blast radius control | [Decision doc](week-02-vpc-networking-security/docs/vpc-architecture.md) |
| 3 | [EC2 + ASG + ALB](week-03-ec2-asg-alb-high-availability/) | Can build HA that self-heals and explain the cost | [Runbook](week-03-ec2-asg-alb-high-availability/docs/alb-asg-runbook.md) |
| 4 | [Storage Strategy](week-04-s3-ebs-efs-storage-strategy/) | Can pick the right storage tier and defend it with numbers | [Decision doc](week-04-s3-ebs-efs-storage-strategy/docs/DECISIONS.md) |
| 5 | [Terraform IaC](week-05-terraform-fundamentals-modules/) | Can codify infrastructure, keep dev and prod in separate state, deploy each in one command | [Decision doc](week-05-terraform-fundamentals-modules/docs/DECISIONS.md) |
| 6 | [Docker + Containers](week-06-docker-container-fundamentals/) | Can containerize a workload, shrink it with a slim base image, and harden it | [Decision doc](week-06-docker-container-fundamentals/docs/DECISIONS.md) |

---

## LinkedIn Articles

- **Week 6:** [My Docker image was 900 MB. Here is how I cut it to 130 MB.](https://www.linkedin.com/pulse/my-docker-image-900-mb-here-how-i-cut-130-why-dow-cares-fresco-f499e/)
- **Week 5:** [Terraform Deployed My Entire AWS Architecture Under 5 Minutes](https://www.linkedin.com/pulse/terraform-deployed-my-entire-aws-architecture-under-5-fresco-glife/)
- **Week 4:** [AWS Storage: How Access Patterns, Benchmarks, and Cost Should Drive Every Decision](https://www.linkedin.com/pulse/aws-storage-options-first-principles-guide-sebasti%C3%A3o-fresco-jrose/)
- **Week 3:** [What Happens When an EC2 Instance Fails in Production?](https://www.linkedin.com/pulse/what-happens-when-ec2-instance-fails-production-alb-auto-fresco-znj9e/)
- **Week 2:** [How Network Boundaries Actually Work in AWS](https://www.linkedin.com/pulse/i-built-production-grade-vpc-from-scratch-heres-what-learned-fresco-gmome/)

---

Each week has a README and `docs/` (decision docs, runbooks). Most have `infra/` (diagrams) and `notes/` (handwritten scans). Terraform is in Week 5 and in Week 6 `infra/`.

---

## What I'd do differently

Errors and gaps I know about and did not fix in place:

- Weeks 1-4 were built in the Console, so they cannot be rerun from code. Building them in Terraform would fix that.
- Week 3 does not record whether the instances had public IPs, so its IPv4 cost is a range.
- Week 4 `decision_matrix.png` still shows the January 2026 figures. The [markdown matrix](week-04-s3-ebs-efs-storage-strategy/docs/storage-decision-matrix.md) has the corrections.
- Week 4 gp3 benchmarks are above the gp3 baseline, so fio probably measured the page cache. They need a rerun with `--direct=1`.
- Week 4 never sets the access-logs expiry against a defined AU-11 retention period.
- Week 5 `envs/` layout passes `terraform validate` but has not been applied since I split dev and prod.
- Week 6 ECR lifecycle policy only expires untagged images, so tagged versions pile up forever. It needs a rule that keeps the last N tags.
- Week 6 scan-on-push is basic scanning, which skips the Python packages. Enhanced scanning would cover them.
