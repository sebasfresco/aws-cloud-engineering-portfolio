# ============================================================
# STAGE 1: Builder
# Purpose: Install dependencies in a full environment
# This stage is thrown away. It does not end up in the final image.
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

# Create a non-root user for security
# Running as root inside a container is a security risk
# If an attacker escapes the container, they have root on the host
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy the virtual environment from the builder stage
# This is the key: we only copy the installed packages, not pip/setuptools/etc.
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application code
COPY app.py .

# Switch to non-root user
USER appuser

EXPOSE 5000

# Health check instruction (optional but good practice)
# Docker/ECS can use this to determine container health
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

CMD ["python", "app.py"]
