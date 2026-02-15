variable "project_name" { type = string }
variable "environment" { type = string}

variable "vpc_cidr" {
  description = "The IP range for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description  = "List of public subnet CIDRs"
  type         = list(string)
  default      = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description  = "List of private subnet CIDRs"
  type         = list(string)
  default      = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
