
provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "three-tier-vpc"
  cidr   = "10.0.0.0/16"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "three-tier-cluster"
  cluster_version = "1.24"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
}

module "iam" {
  source = "./iam_roles.tf"
}

resource "aws_rds_instance" "app_db" {
  identifier              = "three-tier-db"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  name                    = "app_db"
  username                = "admin"
  password                = "adminpassword"
  vpc_security_group_ids  = [module.vpc.default_security_group_id]
}
