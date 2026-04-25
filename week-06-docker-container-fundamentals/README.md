# Week 6 — Docker + Container Fundamentals

> **What this proves:** Can containerize a workload with multi-stage builds,
> push to ECR with Terraform-managed infrastructure, and orchestrate
> multi-container applications.

## What I Built

| Category | Resource | Details |
|----------|----------|---------|
| Application | Flask web app | Python 3.12, health check endpoint, Redis integration |
| Container | Multi-stage Dockerfile | Builder + production stages, non-root user, HEALTHCHECK |
| Registry | ECR repository | Terraform-managed, scan-on-push, lifecycle policy |
| Networking | Docker Compose | Flask + Redis on custom bridge network |
| IaC | Terraform ECR Module | Reusable module with scanning, encryption, lifecycle |

## What I Tested

- Layer caching: verified pip install skips when only app code changes
- Port conflicts: confirmed two containers cannot bind the same host port
- Network isolation: default bridge cannot resolve names, custom bridge can
- Non-root: confirmed container runs as appuser, not root
- Health checks: verified Docker HEALTHCHECK reports healthy status
- ECR scanning: pushed image, reviewed CVE scan results

## Key Decisions

See [docs/DECISIONS.md](docs/DECISIONS.md)

## Dockerfile Best Practices

See [docs/DOCKERFILE-BEST-PRACTICES.md](docs/DOCKERFILE-BEST-PRACTICES.md)

## Prerequisites

| Requirement | Version |
|-------------|---------|
| Docker Desktop | Latest |
| Terraform | >= 1.5.0 |
| AWS CLI v2 | Configured |
| Python | 3.12 (insider container only) |

## Quick Start

### Run locally

docker compose up -d --build

# Visit <http://localhost:5001>

### Push to ECR

cd infra && terraform apply
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
docker build -t flask-app:v3.0.0 app/
docker tag flask-app:v3.0.0 <ecr-url>:v3.0.0
docker push <ecr-url>:v3.0.0

## Cost

| Resource | Monthly Cost |
|----------|-------------|
| ECR storage (10 images @ ~130MB) | ~$0.13 |
| ECR data transfer | $0.00 (same-region pulls) |
| **Total** | **~$0.13/month** |

## Tear Down

docker compose down -v
cd infra && terraform destroy
