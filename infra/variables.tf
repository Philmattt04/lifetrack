variable "domain" {
  description = "Root domain"
  default     = "philmathieu.com"
}

variable "app_domain" {
  description = "LifeTrack subdomain"
  default     = "lifetrack.philmathieu.com"
}

variable "bucket_name" {
  description = "S3 bucket for web assets"
  default     = "lifetrack-philmathieu-web"
}

variable "anthropic_api_key" {
  description = "Anthropic API key for Lambda"
  sensitive   = true
}
