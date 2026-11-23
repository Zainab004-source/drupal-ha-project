# Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Drupal application server in AZ 1a
resource "aws_instance" "drupal_a" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = aws_key_pair.drupal_key.key_name

  associate_public_ip_address = true

  tags = {
    Name    = "Drupal-Server-A"
    Project = "Drupal-HA"
  }
}

# Drupal application server in AZ 1b
resource "aws_instance" "drupal_b" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_b.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = aws_key_pair.drupal_key.key_name

  associate_public_ip_address = true

  tags = {
    Name    = "Drupal-Server-B"
    Project = "Drupal-HA"
  }
}

# Application Load Balancer
resource "aws_lb" "drupal_alb" {
  name               = "drupal-ha-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name    = "Drupal-HA-ALB"
    Project = "Drupal-HA"
  }
}

# Target group
resource "aws_lb_target_group" "drupal_tg" {
  name     = "drupal-ha-targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.drupal_vpc.id
  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 3600
  }

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "Drupal-HA-Target-Group"
  }
}

# Register both Drupal servers
resource "aws_lb_target_group_attachment" "drupal_a" {
  target_group_arn = aws_lb_target_group.drupal_tg.arn
  target_id        = aws_instance.drupal_a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "drupal_b" {
  target_group_arn = aws_lb_target_group.drupal_tg.arn
  target_id        = aws_instance.drupal_b.id
  port             = 80
}

# HTTP listener
resource "aws_lb_listener" "drupal_http" {
  load_balancer_arn = aws_lb.drupal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.drupal_tg.arn
  }
}
