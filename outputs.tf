# userPoolId
output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

# userPoolClientId
output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.app_client.id
}

# invokeUrl
output "lambda_base_url" {
  value = aws_api_gateway_deployment.wildrydes_api_deployment.invoke_url
}

# cloudFrontID
output "cloudfront_id" {
  value = aws_cloudfront_distribution.wildrydes_distribution.domain_name
}





