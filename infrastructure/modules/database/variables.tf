variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "vpc_cidr" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "bastion_sg_id" {
  description  = "Security Group ID of the Bastion Host"
  type         = string
  default      = null
}
