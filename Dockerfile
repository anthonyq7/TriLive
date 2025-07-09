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

# 1) Bring in all your code
COPY backend ./backend

# 2) EXPOSE the default (optional, for docs)
EXPOSE 8000

# 3) Run via sh -c so $PORT is expanded
ENTRYPOINT ["sh","-c"]
CMD ["exec gunicorn -k uvicorn.workers.UvicornWorker backend.app.main:app --bind 0.0.0.0:${PORT:-8000}"]
