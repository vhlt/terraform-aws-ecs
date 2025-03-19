// Security group for Application Load Balancer (ALB)
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  // Inbound rules
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow inbound HTTPS traffic from anywhere
  }

  // Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" // Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-security-group"
  }
}

// Security group for ECS services
resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs-service-security-group"
  description = "Security group for ECS services"
  vpc_id      = module.vpc.vpc_id

  // Inbound rules
  ingress {
    from_port       = var.api_port
    to_port         = var.api_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] // Allow inbound traffic from ALB
  }

  ingress {
    from_port       = var.web_port
    to_port         = var.web_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] // Allow inbound traffic from ALB
  }

  // Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" // Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-service-security-group"
  }
}

// Security group for DB postgres
resource "aws_security_group" "db_sg" {
  name        = "db-security-group"
  description = "Security group for DB"
  vpc_id      = module.vpc.vpc_id

  // Inbound rules
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service_sg.id] // Allow inbound HTTP traffic from ALB
  }

  // Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" // Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-security-group"
  }
}