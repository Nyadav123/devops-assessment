resource "aws_security_group" "rds" {
  name        = "rds-sg-${var.environment}"
  description = "Allow inbound traffic exclusively from ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Environment = var.environment }
}

resource "aws_db_subnet_group" "main" {
  name       = "rds-subnet-group-${var.environment}"
  subnet_ids = var.private_subnet_ids

  tags = { Environment = var.environment }
}

resource "aws_db_instance" "main" {
  identifier             = "postgres-${var.environment}"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  skip_final_snapshot    = var.environment == "dev" ? true : false

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection

  tags = { Environment = var.environment }
}
