output "db_endpoint" {
    value = aws_db_instance.main.address
}

output "secret_arn" {
    value = aws_secretsmanager_secret.db_credentials.arn
}

output "security_group_id" {
    value = aws_security_group.rds_sg.id
}