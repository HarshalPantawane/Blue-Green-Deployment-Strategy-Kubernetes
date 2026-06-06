resource "aws_security_group" "vpc_security" {
  name = "${var.environment}-vpc-security-group"
  description = "vpc security group"
  vpc_id = var.vpc_id

  ingress = [
    for port in [80, 443] : { 
    from_port = port
    to_port = port
    protocol = "tcp"
    cidr_blocks = ["var.vpc_cidr"]
   }
 ]

 egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
  
} 