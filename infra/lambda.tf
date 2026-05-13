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

resource "aws_lambda_function_url" "insights" {
  function_name      = aws_lambda_function.insights.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = false
    allow_origins     = ["https://${var.app_domain}", "http://localhost:*"]
    allow_methods     = ["POST"]
    allow_headers     = ["Content-Type"]
    max_age           = 86400
  }
}
