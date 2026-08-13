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

output "api_url" {
  description = "API Gateway endpoint — paste this into lib/services/claude_service.dart"
  value       = "${aws_apigatewayv2_stage.insights.invoke_url}/insights"
}
