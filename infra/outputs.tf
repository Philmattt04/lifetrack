output "app_url" {
  value = "https://${var.app_domain}"
}

output "cloudfront_id" {
  description = "CloudFront distribution ID — needed for cache invalidation after deploys"
  value       = aws_cloudfront_distribution.web.id
}

output "s3_bucket" {
  value = aws_s3_bucket.web.bucket
}

output "lambda_url" {
  description = "Lambda Function URL — paste this into lib/services/claude_service.dart"
  value       = aws_lambda_function_url.insights.function_url
}
