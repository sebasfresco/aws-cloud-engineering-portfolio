# ============================================================
# STAGE 1: Builder
# Purpose: Install dependencies into a virtual environment
# This stage is thrown away. It does not end up in the final image.
#
# Where the size came from: switching the base from python:3.12
# to python:3.12-slim is what cut the image by about 7x. Both
# stages use the same slim base, so the multi-stage build saves
# almost nothing here (I measured a single-stage slim build at
# the same size). It starts paying off when the builder needs
# compilers or headers that the runtime does not.
# ============================================================
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .

# Install dependencies into a virtual environment
# The venv gives us a clean, self-contained directory to copy
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

# ============================================================
# STAGE 2: Production
# Purpose: Minimal image with only what is needed to RUN the app
# ============================================================
FROM python:3.12-slim

# Create a non-root user with a fixed numeric UID and GID
# Running as root inside a container is a security risk
# If an attacker escapes the container, they have root on the host
RUN groupadd -r -g 10001 appuser && useradd -r -u 10001 -g appuser appuser

WORKDIR /app

# Copy the virtual environment from the builder stage
# The venv includes its own pip, and the slim base has pip too, so
# this does not remove pip from the final image. It copies the
# installed packages without rerunning the install.
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application code
COPY app.py .

# Switch to the non-root user by number, not name. Kubernetes
# runAsNonRoot can only verify a numeric user; with a name it
# refuses to start the container.
USER 10001:10001

EXPOSE 5000

# Health check instruction (optional but good practice)
# Docker and ECS can use this. Kubernetes ignores it and uses its own probes.
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# gunicorn, not "python app.py". app.run() starts Flask's
# development server, which Flask says not to use in production.
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
