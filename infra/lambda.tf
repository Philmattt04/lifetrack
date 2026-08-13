data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "insights" {
  function_name    = "lifetrack-insights"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda.arn
  timeout          = 60

  environment {
    variables = {
      ANTHROPIC_API_KEY = var.anthropic_api_key
    }
  }
}

# ── API Gateway HTTP API ──────────────────────────────────────────────────────

resource "aws_apigatewayv2_api" "insights" {
  name          = "lifetrack-insights-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
    max_age       = 86400
  }
}

resource "aws_apigatewayv2_integration" "insights" {
  api_id                 = aws_apigatewayv2_api.insights.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.insights.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "insights" {
  api_id    = aws_apigatewayv2_api.insights.id
  route_key = "POST /insights"
  target    = "integrations/${aws_apigatewayv2_integration.insights.id}"
}

resource "aws_apigatewayv2_stage" "insights" {
  api_id      = aws_apigatewayv2_api.insights.id
  name        = "$default"
  auto_deploy = true

  # Public LinkedIn demo has no auth in front of this endpoint — cap request
  # volume so it can't be scripted into a large Anthropic API bill.
  default_route_settings {
    throttling_burst_limit = 5
    throttling_rate_limit  = 2
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.insights.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.insights.execution_arn}/*/*"
}
