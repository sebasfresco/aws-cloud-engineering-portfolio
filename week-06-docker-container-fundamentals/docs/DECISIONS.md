# Containers (ECS / Fargate) -- Decision Document

## Why Containers Over VMs

### The Problem

Deploying applications on EC2 instances means managing the full OS, patching, runtime installation, and configuration drift between environments. "Works on my machine" is a real failure mode when dev, staging, and prod have different library versions.

### Containers Solve This

A container packages the application, its dependencies, and its runtime in a single artifact. The same image runs identically on a developer laptop, in CI/CD, and in production. There is no configuration drift because the environment IS the artifact.

### Trade-offs

| Factor | VMs (EC2) | Containers |
|--------|-----------|------------|
| Startup time | 1-3 minutes | 1-5 seconds |
| Resource overhead | Full OS per instance | Shared kernel, MB-level overhead |
| Density | Dozens per host | Hundreds per host |
| Isolation | Hardware-level (hypervisor) | Process-level (kernel namespaces) |
| Portability | AMI is AWS-specific | Image runs anywhere Docker runs |
| Security boundary | Stronger (separate kernels) | Weaker (shared kernel) |
| Cost at scale | Higher (paying for idle OS overhead) | Lower (higher density per host) |

### When VMs Are Still the Right Choice

- Workloads requiring kernel-level isolation (multi-tenant with strict security)
- Legacy applications that cannot be containerized
- Windows workloads with specific OS dependencies
- GPU workloads where direct hardware access matters

## Base Image Selection

### Why It Matters

The base image is the foundation of every container. A bloated base image means:

- Larger attack surface (more packages = more CVEs)
- Slower image pulls (important for auto-scaling speed)
- Higher ECR storage costs

### Image Size Comparison (Python 3.12)

| Base Image | Approx Size | Use Case |
|------------|-------------|----------|
| python:3.12 | ~900 MB | Development only, never production |
| python:3.12-slim | ~130 MB | Production default |
| python:3.12-alpine | ~50 MB | Smallest, but musl libc can cause compatibility issues |

### Our Choice

python:3.12-slim. It balances size with compatibility. Alpine is smaller but uses musl instead of glibc, which breaks some Python packages that depend on C extensions.

## ECR Configuration Decisions

### Image Tag Mutability: IMMUTABLE

Once pushed, a tag like v2.0.0 cannot be overwritten. This guarantees that "v2.0.0" in staging is the exact same image as "v2.0.0" in production. Mutable tags (like "latest") can change without notice and break auditability.

### Scan on Push: Enabled

Every pushed image is automatically scanned for CVEs. In a CI/CD pipeline, you would gate deployment on scan results (zero critical/high findings).

### Lifecycle Policy: 14-day Untagged Expiry

When you push a new "v2.0.0" to an IMMUTABLE repo, the old image becomes untagged. Without cleanup, these accumulate and increase ECR storage costs ($0.10/GB-month). The lifecycle policy auto-deletes them after 14 days, providing a rollback window without unbounded cost growth.

### Cost

ECR storage: $0.10/GB-month
ECR data transfer: $0.09/GB (cross-region pulls)
At out image size (~130MB), storing 10 tagged versions costs ~$0.13/month.

## Container Networking Decisions

### Docker Compose Default Network

Docker Compose automatically creates a custom bridge network for each project. Services resolve each other by service name via built-in DNS. This is simpler and more reliable than linking containers manually.

### Network Types and When to Use Each

| Network Type | Use Case |
|-------------|----------|
| Default bridge | Never in production. No DNS, fragile IP-based communication. |
| Custom bridge | Multi-container apps on a single host. Built-in DNS. |
| Host | Performance-critical apps needing bare-metal networking (rare). |
| None | Batch jobs or security-sensitive workloads with no network needs. |

### ECS Equivalent

In ECS, the equivalent of Docker Compose networking is the "awsvpc" network mode, where each task gets its own ENI and private IP in your VPC. Service discovery replaces Docker DNS. This is covered in Week 7.
