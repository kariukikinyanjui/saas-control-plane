# The Virtual Private Cloud
resource "aws_vpc" "main" {
  cidr_block            = var.vpc_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name = "${var.project_name}-vpc-${var.environment}"
  }
}

# 2. The Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw-${var.environment}"
  }
}

# 3. Public Subnets (For Load Balancers & Bastion Hosts)
resource "aws_subnet" "public" {
  count                    = length(var.public_subnets)  
  vpc_id                   = aws_vpc.main.id
  cidr_block               = var.public_subnets[count.index]
  availability_zone        = var.azs[count.index]
  map_public_ip_on_launch  = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Type = "Public"
  }
}

# 4. Private Subnets (The "Vault" - For RDS & Lambda)
resource "aws_subnet" "private" {
  count              = length(var.private_subnets)
  vpc_id             = aws_vpc.main.id
  cidr_block         = var.private_subnets[count.index]
  availability_zone  = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-private_subnet-${count.index + 1}"
    Type = "Private"
  }
}

# 5. Public Route Table (Traffic -> Internet Gateway)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# 6. Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count           = length(var.public_subnets)
  subnet_id       = aws_subnet.public[count.index].id
  route_table_id  = aws_route_table.public.id
}
