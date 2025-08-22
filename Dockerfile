# Use AWS Lambda Python base image (runtime interface client baked in)
FROM public.ecr.aws/lambda/python:3.12 AS runtime


# Add AWS Lambda Web Adapter (so Flask WSGI can run on Lambda without code changes)
# Docs: https://github.com/awslabs/aws-lambda-web-adapter
# The adapter provides a bootstrap that translates API Gateway/ALB events to HTTP.
ADD https://github.com/awslabs/aws-lambda-web-adapter/releases/latest/download/aws-lambda-adapter.zip /opt/extensions/
RUN cd /opt/extensions && unzip aws-lambda-adapter.zip && rm aws-lambda-adapter.zip


# App code and dependencies
WORKDIR /var/task
COPY requirements.txt ./
RUN python -m pip install --upgrade pip && pip install -r requirements.txt
COPY . .


# The Lambda Web Adapter requires your web server to bind to 0.0.0.0:$PORT
# Flask dev server is fine for light workloads; for heavier ones, install gunicorn
ENV PORT=8080


# Command to start the web server inside Lambda environment
# Use Flask's built-in server for simplicity; swap to gunicorn for prod if needed
# Example gunicorn: gunicorn -b 0.0.0.0:$PORT app:app
CMD ["python", "-c", "from app import app; app.run(host='0.0.0.0', port=8080)" ]