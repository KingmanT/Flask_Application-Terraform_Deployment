variable "aws_access_key" {}
variable "aws_secret_key" {}

# configure aws provider
provider "aws" {
  region = var.region
  #profile = "Admin"
}

# create vpc
module "vpc" {
  source       = "../D4_Terraform_Modules/vpc"
  region       = var.region
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr

}

#create instance
module "instance" {
  source              = "../D4_Terraform_Modules/instance"
  ami                 = var.ami
  instance_type       = var.instance_type
  instance_name       = var.instance_name
  key_name            = var.key_name
  security_group_name = var.security_group_name
  subnet_id           = module.vpc.subnet_id
  vpc_id              = module.vpc.vpc_id
}
