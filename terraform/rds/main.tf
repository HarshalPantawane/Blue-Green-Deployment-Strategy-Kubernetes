resource "aws_db_subnet_group" "rds" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = {
    Name = "${var.environment}-rds-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Allow inbound traffic from EKS nodes to MySQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-rds-sg"
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "rds" {
  identifier             = "${var.environment}-food-delivery-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 100
  storage_type           = "gp3"
  db_name                = "food_delivery"
  username               = var.db_username
  password               = var.db_passwd
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  multi_az               = true
  skip_final_snapshot    = true

  tags = {
    Name = "${var.environment}-food-delivery-db"
  }
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/food-delivery/${var.environment}/db-password"
  description = "Master password for the food delivery RDS database"
  type        = "SecureString"
  value       = random_password.db_password.result

  tags = {
    Environment = var.environment
  }
}
