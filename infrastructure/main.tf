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
  bastion_sg_id      = module.bastion.security_group_id
}

module "bastion" {
  source            = "./modules/bastion"
  project_name      = "saas-control-plane"
  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_ids[0]
}

module "api" {
  source = "./modules/api"

  project_name       = "saas-control-plane"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids


# Pass Database Details
db_endpoint = module.database.db_endpoint
secret_arn  = module.database.secret_arn
rds_sg_id   = module.database.security_group_id
secret_name = "saas-control-plane-db-credentials-dev"
}
