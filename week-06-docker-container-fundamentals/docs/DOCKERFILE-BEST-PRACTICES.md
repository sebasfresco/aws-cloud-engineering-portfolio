# Dockerfile Best Practices

## 1. Order Layers for Cache Efficiency

Put instructions that change infrequently FIRST (dependency installs) and instructions that change frequently LAST (code copy). Every line after a cache-busting change re-executes.

BAD order:
COPY . .                <-- code changes bust cache here
RUN pip install ...     <-- re-installs dependencies every time

GOOD order:
COPY requirements.txt .
RUN pip install ...     <-- cached unless requirements.txt changed
COPY app.py .           <-- only this re-runs when code changes

## 2. Use .dockerignore

Exclude .git, __pycache__, .terraform, *.tfstate, .env, and any file not needed at runtime. Reduces build context size and prevents secrets from leaking into images.

## 3. Use Multi-Stage Builds

Separate build-time dependencies from runtime. The builder stage has compilers, package managers, and header files. The production stage has only the application and its runtime dependencies.

Benefits:

- Smaller images (reduced attack surface for STIG compliance)
- Faster pulls (critical for auto-scaling where every second counts)
- No build tools in production (cannot be exploited)

## 4. Never Run as Root

Always create a non-root user and switch to it with USER.
Running as root means a container escape gives the attacker root on the host.
This is a STIG finding in DoW environments.

## 5. Pin Base Image Versions

BAD:    FROM python:latest      (could change any day, breaking your build)
GOOD:   FROM python:3.12-slim   (predictable, reproducible)

## 6. Use HEALTHCHECK

Tells Docker (and ECS/Kubernetes) how to verify the container is actually working, not just running. A container can be "up" but the application inside it can be crashed.
