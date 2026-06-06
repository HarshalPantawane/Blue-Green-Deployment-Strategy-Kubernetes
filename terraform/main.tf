terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    # Replace with your actual S3 bucket name and DynamoDB table for state locking
    bucket         = "terraform-state-file-storage-bucket-for-my-project"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile    = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./vpc"
  
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  environment          = var.environment
}

module "sg" {
  source = "./sg"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
  
}
module "iam" {
  source = "./iam"
  environment = var.environment
}

module "eks" {
  source = "./eks"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  environment     = var.environment
  
  # Ensure IAM role exists before EKS creation
  depends_on = [module.iam]
}

module "s3" {
  source = "./s3"
  
  environment = var.environment
  bucket_name = var.s3_bucket_name
}

module "rds" {
  source = "./rds"

  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  db_name                    = var.db_name
  db_username                = var.db_username
  db_password                = var.db_password
  eks_node_security_group_id = module.eks.node_security_group_id

  depends_on = [module.vpc, module.eks]
}
