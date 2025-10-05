# syntax=docker/dockerfile:1

############################
# Common base (deps build) #
############################
FROM python:3.12-slim AS base
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app

# System deps (psycopg2-binary is fine without libpq, but keep build-essential for safety)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
  && rm -rf /var/lib/apt/lists/*

# Python deps
COPY requirements.txt .
RUN pip3 install --no-cache-dir --upgrade pip \
  && pip3 install --no-cache-dir -r requirements.txt

# App source
COPY . .

EXPOSE 5000

# Default: run the app (you can override this command to run tests)
CMD ["python3", "app.py"]