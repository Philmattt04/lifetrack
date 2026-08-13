#!/bin/bash
set -e

CLOUDFRONT_ID="ELOPVWMQ8CTFX"
S3_BUCKET="lifetrack-philmathieu-web"

echo "Building Flutter web..."
API_URL=$(cd infra && terraform output -raw api_url)
flutter build web --release \
  --dart-define=API_URL=$API_URL

echo "Uploading to S3..."
aws s3 sync build/web/ s3://$S3_BUCKET/ --delete --quiet

echo "Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
  --distribution-id $CLOUDFRONT_ID \
  --paths "/*" \
  --query 'Invalidation.Status' --output text

echo "Done. Live at https://lifetrack.philmathieu.com"
