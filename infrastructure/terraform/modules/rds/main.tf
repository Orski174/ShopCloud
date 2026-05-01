resource "random_password" "db" {
  length  = 32
  special = true
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

resource "aws_rds_cluster" "main" {
  cluster_identifier              = "shopcloud-${var.env}"
  engine                          = "aurora-postgresql"
  engine_version                  = "15.4"
  database_name                   = var.db_name
  master_username                 = var.db_username
  master_password                 = random_password.db.result
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.rds.id]
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "shopcloud-${var.env}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  backup_retention_period         = var.backup_retention_period
  deletion_protection             = var.deletion_protection
  storage_encrypted               = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name = "shopcloud-${var.env}"
    Env  = var.env
  }
}

resource "aws_rds_cluster_instance" "main" {
  count               = 1  # Single instance for free tier
  cluster_identifier  = aws_rds_cluster.main.id
  instance_class      = "db.t3.micro"  # Free tier eligible
  engine              = aws_rds_cluster.main.engine
  engine_version      = aws_rds_cluster.main.engine_version
  publicly_accessible = false
  auto_minor_version_upgrade = true

  tags = {
    Name = "shopcloud-${var.env}-${count.index + 1}"
    Env  = var.env
  }
}
