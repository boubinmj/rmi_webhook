from aws_lambda_wsgi import response
from app import app

def lambda_handler(event, context):
    headers = event.get("headers") or {}
    headers.setdefault("X-Forwarded-Proto", "https")
    headers.setdefault("Host", "example.com")
    event["headers"] = headers
    return response(app, event, context)