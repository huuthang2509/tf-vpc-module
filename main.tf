terraform {
  backend "s3" {
    key     = "my-vpc"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./vpc"

  region            = var.region
  vpc_cidr_block    = var.vpc_cidr_block
  private_subnets   = var.private_subnets
  public_subnets    = var.public_subnets
  availability_zone = var.availability_zone
}