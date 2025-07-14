FROM python:3.12-slim

# Installs build deps for psycopg2
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

#Switches to the backend folder
WORKDIR /app/backend

#Copy & install only your unified deps
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

#Copy in your ant's FastAPI app
COPY backend/app ./app

#Expose the port
EXPOSE 8000

#Launch with gunicorn + UvicornWorker (so $PORT gets expanded)
ENTRYPOINT ["sh","-c"]
CMD ["exec gunicorn -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:${PORT:-8000}"]
