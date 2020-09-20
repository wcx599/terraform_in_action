

module "vpc" {
  source = "../modules/vpc"

  domain    = var.domain
  user      = var.user
  product = var.product
  region = var.region
  env  = var.env
  vpc_cidr =  var.vpc_cidr
}

