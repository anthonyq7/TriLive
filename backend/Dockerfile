FROM python:3.12-slim

# build deps for psycopg2, etc.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    python3-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# install your Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# copy in the rest of your code
COPY . .

# (optional) document the port your app listens on
EXPOSE 80

# run via sh -c so that $PORT is expanded at runtime
CMD sh -c "exec gunicorn -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:\$PORT"
