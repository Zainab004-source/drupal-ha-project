# Security Group for the Application Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "Drupal-ALB-SG"
  description = "Allow HTTP traffic to the load balancer"
  vpc_id      = aws_vpc.drupal_vpc.id

  ingress {
    description = "HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Drupal-ALB-SG"
  }
}

# Security Group for Drupal Application Servers
resource "aws_security_group" "app_sg" {
  name        = "Drupal-App-SG"
  description = "Allow traffic from the load balancer and restricted SSH"
  vpc_id      = aws_vpc.drupal_vpc.id

  ingress {
    description     = "HTTP from the load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Drupal-App-SG"
  }
}

# Security Group for the Database
resource "aws_security_group" "db_sg" {
  name        = "Drupal-DB-SG"
  description = "Allow MySQL only from Drupal application servers"
  vpc_id      = aws_vpc.drupal_vpc.id

  ingress {
    description     = "MySQL from Drupal application servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Drupal-DB-SG"
  }
}
