FROM python:3.12-slim

RUN apt-get update && apt-get install -y build-essential libpq-dev python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# these paths are relative to the *root* of your git checkout
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/app ./app

EXPOSE 8000
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "app.main:app", "--bind", "0.0.0.0:${PORT:-8000}"]
