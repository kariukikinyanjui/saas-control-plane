output "lambda_arn" {
  value = aws_lambda_function.api_handler.arn
}

output "security_group_id" {
  value = aws_security_group.lambda_sg.id
}
