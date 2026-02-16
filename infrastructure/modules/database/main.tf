# 1. The Database Security Group
resource "aws_security_group" "rds_sg" {
  name         = "${var.project_name}-rds-sg"
  description  = "Allow inbound PostgreSQL traffic from VPC only"
  vpc_id       = var.vpc_id

  # Ingress: Allow Port 5432 from the VPC CIDR (Internal Traffic Only)
  ingress{
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Egress: Allow all outbound (Standard for updates/logging)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# 2. Generate a Secure Random Password
resource "random_password" "db_password" {
  length = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 3. Store the Password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}-db-credentials-${var.environment}"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.db_password.result
    engine = "postgres"
    host = aws_db_instance.main.address
    port = 5432
  })
}

# 4. The Subnet Group (Where the DB lives)
resource "aws_db_subnet_group" "private" {
  name = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# 5. The RDS Instance (PostgreSQL)
resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-postgres"
  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  # Credentials (Pulled from the random generator)
  username = "dbadmin"
  password = random_password.db_password.result

  # Networking
  db_subnet_group_name = aws_db_subnet_group.private.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-postgres"
  }
}