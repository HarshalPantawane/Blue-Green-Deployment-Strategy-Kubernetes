output "cluster_id" {
  value = aws_eks_cluster.main.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "node_security_group_id" {
  # Hacky way to get the SG id, better handled with specific module outputs if using public registry
  value = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id 
}
