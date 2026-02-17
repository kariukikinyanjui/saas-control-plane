variable "project_name" {}
variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }
variable "db_endpoint" {}
variable "secret_arn" {}
variable "secret_name" {}
variable "rds_sg_id" {
  description = "The Security Group ID of the RDS instance"
  type        = string
}
