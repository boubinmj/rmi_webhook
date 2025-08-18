from aws_lambda_wsgi import response
from app import app

def lambda_handler(event, context):
    headers = event.get("headers") or {}

    # For AWS API Gateway
    headers.setdefault("X-Forwarded-Proto", "https")

    # set API headers and params 
    headers.setdefault("Host", "example.com")
    event["headers"] = headers
    return response(app, event, context)