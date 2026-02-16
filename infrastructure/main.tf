provider "aws" {
  region = "us-east-1"
}

module "identity" {
  source       = "./modules/identity"
  project_name = "saas-control-plane"
  environment  = "dev"
}

module "authorization" {
  source = "./modules/authorization"
}

module "governance" {
  source        = "./modules/governance"
  project_name  = "saas-control-plane"
  alert_email   = "michaelkariuki7@gmail.com"
}

module "network" {
  source       = "./modules/network"
  project_name = "saas-control-plane"
  environment  = "dev"
}

module "database" {
  source = "./modules/database"

  project_name = "saas-control-plane"
  environment  = "dev"
  vpc_id       = module.network.vpc_id
  vpc_cidr     = "10.0.0.0/16"
  private_subnet_ids = module.network.private_subnet_ids
}
