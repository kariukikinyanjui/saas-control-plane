# Fetch the secret value so we can inject it
data "aws_secretsmanager_secret_version" "creds" {
  secret_id = var.secret_name
}

# 1. Archive the Python Code
data "archive_file" "lambda_zip" {
  type         = "zip"
  source_file  = "${path.module}/../../../backend/lambda/handler.py"
  output_path  = "${path.module}/lambda_function.zip"
}

# 2. IAM Role (Lambda needs permission to run and talk to the VPC)
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      }]
    })
}

# 3. Attach Permissions (Logs + VPC Access + Secrets Manager)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role        = aws_iam_role.lambda_role.name
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role        = aws_iam_role.lambda_role.name
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_secrets" {
  name = "secrets-access"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = var.secret_arn
    }]
  })
}

# 4. Security Group for Lambda (Allow Outbound to RDS)
resource "aws_security_group" "lambda_sg" {
  name        = "${var.project_name}-lambda-sg"
  description = "Allow Lambda to access RDS"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. The Lambda Function
resource "aws_lambda_function" "api_handler" {
  function_name = "${var.project_name}-api-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout       = 10

  # VPC Config (Connects it to the Private Subnet)
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_HOST     = var.db_endpoint
      DB_NAME     = "postgres"
      # Parse the JSON secret and pass values securely
      DB_USER     = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["username"]
      DB_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["password"]
    }
  }

  # LAYERS: Use a public layer for psycopg2 (This is the magic fix)
  # ARN for us-east-1 Python 3.12
  layers = ["arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p312-psycopg2-binary:2"]
}

# 6. Allow Lambda -> RDS (Injecting rule into the RDS SG)
resource "aws_security_group_rule" "allow_lambda_to_rds" {
  type                      = "ingress"
  from_port                 = 5432
  to_port                   = 5432
  protocol                  = "tcp"
  source_security_group_id  = aws_security_group.lambda_sg.id

  # We need the RDS SG ID passed in as a variable
  security_group_id  = var.rds_sg_id
}
