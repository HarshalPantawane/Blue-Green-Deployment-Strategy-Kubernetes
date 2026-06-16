variable "environment" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "db_username" {
  description = "DB username"
  type = string
}

variable "db_passwd" {
  description = "DB passwd"
  type = string
}

variable "database_subnet_ids" {
  description = "IDs of the private database subnets"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security group ID of the EKS nodes to allow database access"
  type        = string
}
