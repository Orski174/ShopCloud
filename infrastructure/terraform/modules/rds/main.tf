resource "random_password" "db" {
  length  = 32
  special = false
  override_special = ""
}

resource "aws_db_subnet_group" "main" {
  name       = "shopcloud-${var.env}"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "shopcloud-${var.env}"
    Env  = var.env
  }
}

resource "aws_security_group" "rds" {
  name        = "shopcloud-rds-${var.env}"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.allowed_security_group_id]
  }

  tags = {
    Name = "shopcloud-rds-${var.env}"
    Env  = var.env
  }
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "shopcloud/${var.env}/db"
  recovery_window_in_days = 0

  tags = {
    Env = var.env
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
  })
}

resource "aws_db_instance" "main" {
  identifier                = "shopcloud-${var.env}"
  engine                    = "postgres"
  instance_class            = "db.t3.micro"  # Free tier eligible
  allocated_storage          = 20             # Free tier: up to 20 GB
  db_name                   = var.db_name
  username                  = var.db_username
  password                  = random_password.db.result
  db_subnet_group_name      = aws_db_subnet_group.main.name
  vpc_security_group_ids    = [aws_security_group.rds.id]
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "shopcloud-${var.env}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  backup_retention_period   = var.backup_retention_period
  deletion_protection       = var.deletion_protection
  storage_encrypted         = true
  storage_type              = "gp2"
  publicly_accessible       = false
  auto_minor_version_upgrade = true
  multi_az                  = false  # Single AZ for free tier

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name = "shopcloud-${var.env}"
    Env  = var.env
  }
}
