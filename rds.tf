resource "aws_db_instance" "postgresdb" {
  identifier          = "postgresdb-instance"
  allocated_storage   = 20 # GB
  engine              = "postgres"
  engine_version      = "15.7"
  instance_class      = "db.t3.small"
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  publicly_accessible = false
  parameter_group_name   = aws_db_parameter_group.eg_db_parameter_group.name

  # Setting deletion parameters
  skip_final_snapshot = false
  final_snapshot_identifier = "engram-final-snapshot-${var.environment}"
  copy_tags_to_snapshot = true

  db_subnet_group_name = aws_db_subnet_group.postgresdb_subnet_group.name
  # Specify the security group(s) that allow access to the RDS instance
  # Replace sg-12345678 with your actual security group ID
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  # Optionally, specify backups and maintenance window
  backup_retention_period = 7 # days
  maintenance_window      = "Mon:00:00-Mon:03:00"

  # Enable storage encryption
  storage_encrypted   = true
}

resource "aws_db_subnet_group" "postgresdb_subnet_group" {
  name       = "postgresdb-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "Engram DB Subnet Group"
  }
}

resource "aws_db_parameter_group" "eg_db_parameter_group" {
  name        = "eg-param-group"
  family      = "postgres15"

  parameter {
    name  = "rds.force_ssl"
    value = 0
  }
}