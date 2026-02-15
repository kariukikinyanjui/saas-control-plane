provider "aws" {
  region = "us-east-1"
}

module "identity" {
  source       = "./modules/identity"
  project_name = "saas-control-plane"
  environment  = "dev"
}
