# backend/Dockerfile
FROM python:3.12-slim

# 1) System deps for psycopg2
RUN apt-get update \
&& apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    python3-dev \
&& rm -rf /var/lib/apt/lists/*

# 2) Put everything under /app
WORKDIR /app

# 3) Install only your pip-deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4) Copy in your FastAPI app
COPY app/ ./app

# 5) Expose & launch
EXPOSE 8000
ENTRYPOINT ["sh","-c"]
CMD ["exec gunicorn -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:${PORT:-8000}"]
