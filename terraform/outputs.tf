output "vpc_id" {
  description = "The VPC ID"
  value       = module.vpc.vpc_id
}

output "eks_cluster_endpoint" {
  description = "The EKS cluster control plane endpoint"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "The RDS database endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_address" {
  description = "The RDS database address"
  value       = module.rds.rds_address
}
