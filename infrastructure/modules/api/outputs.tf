output "lambda_arn" {
  value = aws_lambda_function.api_handler.arn
}

output "security_group_id" {
  value = aws_security_group.lambda_sg.id
}

output "api_gateway_url" {
  description = "The public URL of the API Gateway"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}
