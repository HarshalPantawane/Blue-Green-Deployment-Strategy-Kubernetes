# AWS Region and Environment Settings
aws_region  = "us-east-1"
environment = "prod"

# VPC Settings
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]



# EKS Settings
eks_cluster_name    = "prod-food-delivery-cluster"
eks_cluster_version = "1.34"

# S3 Settings
s3_bucket_name = "prod-food-delivery-artifacts"

# RDS Settings
db_username  = "admin"
db_passwd    = "admin123"