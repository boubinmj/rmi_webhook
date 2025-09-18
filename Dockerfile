# syntax=docker/dockerfile:1

############################
# Common base (deps build) #
############################
FROM python:3.12-slim AS deps
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && \
    rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

###############
# Target: web #
###############
FROM python:3.12-slim AS web
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=deps /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=deps /usr/local/bin /usr/local/bin
COPY --from=deps /app /app
EXPOSE 8000
# Serve Flask via Gunicorn
CMD ["gunicorn", "-w", "2", "-k", "gthread", "-b", "0.0.0.0:8000", "app:app"]

#################
# Target: lambda#
#################
# AWS Lambda Python base image for container functions
FROM public.ecr.aws/lambda/python:3.12 AS lambda
# Copy installed deps & app code
COPY --from=deps /var/lang /var/lang
COPY --from=deps /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=deps /usr/local/bin /usr/local/bin
COPY --from=deps /app /var/task
# The Lambda base image already sets the ENTRYPOINT.
# We just need to specify the handler as CMD:
CMD ["lambda_handler.lambda_handler"]