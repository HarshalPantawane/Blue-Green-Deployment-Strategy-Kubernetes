variable "environment" {}
variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "eks_node_security_group_id" {}
