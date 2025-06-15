# Use a Python base image
FROM python:3.13-slim as builder

# Set environment variables
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# Install system dependencies for PostgreSQL client and other build essentials
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
        libpq-dev \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create a directory for your app
RUN mkdir /app

# Set the working directory
WORKDIR /app

# Upgrade pip
RUN pip install --upgrade pip

# Copy requirements file and install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# --- Start of the final stage ---
FROM python:3.13-slim

# Install runtime dependencies for PostgreSQL client
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
        libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create app user and directory
RUN useradd -m -r appuser && mkdir -p /app/static /app/media && chown -R appuser:appuser /app

# Copy installed Python packages from the builder stage
COPY --from=builder /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/

# Set the working directory
WORKDIR /app

# Copy the rest of your application code
COPY --chown=appuser:appuser . .

# Change to the app user
USER appuser

# Expose the port your Django app listens on
EXPOSE 8000

# Command to run your application using Gunicorn
CMD ["sh", "-c", "python manage.py migrate && python manage.py collectstatic --noinput && gunicorn --bind 0.0.0.0:8000 resume_reviewer_backend.wsgi:application"]
