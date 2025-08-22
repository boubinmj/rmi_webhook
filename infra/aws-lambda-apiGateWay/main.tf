terraform {
role = aws_iam_role.lambda_exec.name
policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# Image URI constructed from ECR + tag
data "aws_caller_identity" "current" {}


locals {
account_id = data.aws_caller_identity.current.account_id
image_uri = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.app}:${var.image_tag}"
}


# Lambda function using container image
resource "aws_lambda_function" "fn" {
function_name = local.app
role = aws_iam_role.lambda_exec.arn
package_type = "Image"
image_uri = local.image_uri


memory_size = var.memory_mb
timeout = var.timeout_s


environment {
variables = {
PORT = "8080"
FLASK_ENV = "production"
}
}


depends_on = [aws_cloudwatch_log_group.lambda]
}


# API Gateway HTTP API (v2)
resource "aws_apigatewayv2_api" "http" {
name = "${local.app}-http-api"
protocol_type = "HTTP"
}


# Lambda integration
resource "aws_apigatewayv2_integration" "lambda" {
api_id = aws_apigatewayv2_api.http.id
integration_type = "AWS_PROXY"
integration_uri = aws_lambda_function.fn.invoke_arn
payload_format_version = "2.0"
}


# Routes: ANY / and ANY /{proxy+}
resource "aws_apigatewayv2_route" "root" {
api_id = aws_apigatewayv2_api.http.id
route_key = "$default"
target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}


# Default stage with auto-deploy
resource "aws_apigatewayv2_stage" "default" {
api_id = aws_apigatewayv2_api.http.id
name = "$default"
auto_deploy = true
}


# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigw" {
statement_id = "AllowAPIGwInvoke"
action = "lambda:InvokeFunction"
function_name = aws_lambda_function.fn.arn
principal = "apigateway.amazonaws.com"
source_arn = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}