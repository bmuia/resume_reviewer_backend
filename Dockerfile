# -------------------------
# Build Stage (No changes needed here)
# -------------------------
FROM python:3.13-slim as builder

# Environment setup
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    libpq-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
RUN mkdir /app

WORKDIR /app

# Upgrade pip
RUN pip install --upgrade pip

# Copy and install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# -------------------------
# Final Stage (Updated)
# -------------------------
FROM python:3.13-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create the appuser
RUN useradd -m -r appuser

WORKDIR /app

# Copy installed Python packages from builder
COPY --from=builder /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/

# Copy project files first. Ownership of these files will be set to appuser.
COPY --chown=appuser:appuser . .

# Explicitly ensure the static and media directories exist and are fully writable by appuser.
# Remove existing static/media content to prevent permission conflicts from previous layers
# Then recreate them owned by appuser with full permissions.
RUN rm -rf /app/static /app/media \
    && mkdir -p /app/static /app/media \
    && chown -R appuser:appuser /app/static /app/media \
    && chmod -R u+rwx /app/static /app/media

# It might also be beneficial to ensure the /app directory itself has proper permissions
# for appuser to manage its contents, which includes static/media.
RUN chown -R appuser:appuser /app
RUN chmod -R u+rwx /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8000

# Run app with migrations and static collection
CMD ["sh", "-c", "python manage.py migrate && python manage.py collectstatic --noinput && gunicorn --bind 0.0.0.0:8000 resume_reviewer_backend.wsgi:application"]