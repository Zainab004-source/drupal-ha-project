
# Database subnet group
resource "aws_db_subnet_group" "drupal_db_subnet_group" {
  name = "drupal-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "Drupal-DB-Subnet-Group"
  }
}

# Managed MySQL database
resource "aws_db_instance" "drupal_db" {
  identifier        = "drupal-ha-database"
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "drupaldb"
  username = "drupaladmin"
  password = var.db_password
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.drupal_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period    = 1
  auto_minor_version_upgrade = true

  deletion_protection = false
  skip_final_snapshot = true
  apply_immediately   = true

  tags = {
    Name    = "Drupal-HA-Database"
    Project = "Drupal-HA"
  }
}
