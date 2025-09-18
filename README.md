## Features
- Text Responses
- Integration with various chatbot products
- Stores information in S3 

# RMI Webhook

A minimal Flask webhook that integrates with a GenAI/Admissions chatbot to collect **name** and **email** from interested users and persist submissions to **Amazon S3**. The service runs locally via Docker or deploys serverlessly on **AWS Lambda** behind **API Gateway**.

> Built for a “Request More Information” (RMI) flow in an Admissions chatbot.

---

## ✨ Features

- **Webhook endpoint** for chatbot platforms (Dialogflow CX, custom bots, etc.)
- **S3 persistence** of form submissions (JSON or CSV-like records)
- **Stateless HTTP** responses suitable for bot fulfillment
- **Containerized** for local dev; **serverless** in production (Lambda + API Gateway)
- **input validation** and basic anti-spam guardrails

## Run with Docker
```docker build -t rmi-webhook:dev .
docker run --rm -p 8080:8080 \
  -e AWS_REGION=us-east-1 \
  -e S3_BUCKET=admissions-rmi-submissions \
  rmi-webhook:dev
  ```