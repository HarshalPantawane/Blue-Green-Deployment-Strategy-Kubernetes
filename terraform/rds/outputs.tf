output "rds_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.rds.endpoint
}

output "rds_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.rds.address
}

output "rds_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.rds.port
}
