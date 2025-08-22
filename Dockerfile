# Dockerfile (Lambda + Web Adapter) — robust
FROM public.ecr.aws/docker/library/python:3.12-slim AS base
WORKDIR /var/task

# 1) Copy the Lambda Web Adapter binary from ECR (pin a version)
FROM public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 AS adapter
# (no commands; we just need /lambda-adapter from this stage)

# 2) Your runtime image
FROM public.ecr.aws/docker/library/python:3.12-slim
WORKDIR /var/task

# Minimal system deps (optional)
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

# App deps
COPY requirements.txt .
RUN python -m pip install --upgrade pip && pip install -r requirements.txt

# App code
COPY . .

# Copy the adapter binary into the Lambda extensions folder
COPY --from=adapter /lambda-adapter /opt/extensions/lambda-adapter

# Web server settings
ENV PORT=8080

# Start your Flask app (the adapter forwards API GW events to this HTTP server)
CMD ["python", "-c", "from app import app; app.run(host='0.0.0.0', port=8080)"]
