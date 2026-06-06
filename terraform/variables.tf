variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  type    = list(string)
}

variable "private_subnet_cidrs" {
  type    = list(string)
}

variable "availability_zones" {
  type    = list(string)
}

variable "db_name" {
  type    = string
}

variable "db_username" {
  type    = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for artifacts"
  type        = string
}
