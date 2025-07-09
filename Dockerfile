FROM python:3.12-slim

# Install build deps for psycopg2
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your backend code
COPY backend/app ./backend/app

# Expose FastAPI port
EXPOSE 8000

# run uvicorn, letting PORT default to 8000 if not set
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "backend.app.main:app", "--bind", "0.0.0.0:8000"]
