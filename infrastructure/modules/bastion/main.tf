# 1. Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 2. Security Group (Allow SSH from ANYWHERE)
# In production, you would restrict this to your specific IP address.
resource "aws_security_group" "bastion_sg" {
  name         = "${var.project_name}-bastion-sg"
  description  = "Allow SSH access"
  vpc_id       = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Secure this later
  }

  egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }
}

# 3. The SSH Key Pair
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 4. Create the Key Pair in AWS
resource "aws_key_pair" "generated_key" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

# 5. Save the Private Key locally
resource "local_file" "private_key" {
  content          = tls_private_key.bastion_key.private_key_pem
  filename         = "${path.module}/bastion-key.pem"
  file_permission  = "0400" # Read only
}

# 6. The Bastion Instance
resource "aws_instance" "bastion" {
  ami                          = data.aws_ami.amazon_linux.id
  instance_type                = "t2.micro"
  subnet_id                    = var.public_subnet_id
  vpc_security_group_ids       = [aws_security_group.bastion_sg.id]
  key_name                     = aws_key_pair.generated_key.key_name
  associate_public_ip_address  = true

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

