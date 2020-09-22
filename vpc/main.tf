terraform {
  required_version = "~> 0.12.29"

  backend "s3" {
    bucket         = "${var.product}-${var.region}-${var.env}-remote-state"
    key            = "vpc/terraform.state"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform_locks"
  }
}

module "vpc" {
  source = "../modules/vpc"

  domain    = var.domain
  user      = var.user
  product = var.product
  region = var.region
  env  = var.env
  vpc_cidr =  var.vpc_cidr
  availability_zones = var.availability_zones
}

