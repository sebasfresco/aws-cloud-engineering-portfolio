# Week 10 -- Terraform 3-Tier Production Architecture

> **What this proves:** Can design a 3-tier production architecture in Terraform with separate environments and remote state.

## Status: Planned

## What I will build

- 3-tier architecture: web, app, database tiers
- Remote state backend (S3 + DynamoDB locking)
- Separate dev/staging/prod environments
- Private subnets with NAT for app and database tiers
- RDS or Aurora in private subnets with encryption at rest

## Decision doc

- [`docs/DECISIONS.md`](./docs/DECISIONS.md) (pending)

## Architecture diagram

- `infra/` (pending)
