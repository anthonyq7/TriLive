# backend/Dockerfile
FROM python:3.12-slim

# Install build deps for psycopg2
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy & install only your dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy in your FastAPI code
COPY app/ ./app

# Expose the port your app will run on
EXPOSE 8000

# Launch with Gunicorn + UvicornWorker so that $PORT gets picked up
ENTRYPOINT ["sh","-c"]
CMD ["exec gunicorn -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:${PORT:-8000}"]
