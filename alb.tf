resource "aws_lb" "engram_alb" {
  name               = "engram-alb"
  internal           = false // Set to false for public ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets // Use public subnets

  tags = {
    Name = "engram-alb"
  }
}

// Define target group for backend service
resource "aws_lb_target_group" "backend_tg" {
  name        = "backend-target-group"
  port        = var.api_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = var.health_check_path_backend_tg
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "backend-target-group"
  }
}

// Define target group for frontend service
resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend-target-group"
  port        = var.web_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = var.health_check_path_frontend_tg
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "frontend-target-group"
  }
}

// HTTP listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.engram_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
  }
}

# resource "aws_lb_listener_rule" "frontend_domain_host_rule" {
#   listener_arn = aws_lb_listener.http_listener.arn
#   priority     = 1  # Set the priority for this rule

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.frontend_tg.arn
#   }

#   condition {
#     host_header {
#       values = [var.domain_name_frontend]
#     }
#   }
# }

# resource "aws_lb_listener_rule" "backend_domain_host_rule" {
#   listener_arn = aws_lb_listener.http_listener.arn
#   priority     = 2  # Set the priority for this rule

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.backend_tg.arn
#   }

#   condition {
#     host_header {
#       values = [var.domain_name_backend]
#     }
#   }
# }

// HTTPS listener
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.engram_alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.specific_domain_cert_arn

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_certificate" "wildcard_cert" {
  listener_arn    = aws_lb_listener.https_listener.arn
  certificate_arn =  var.wildcard_domain_cert_arn # Wildcard certificate
}


resource "aws_lb_listener_rule" "frontend_https_domain_host_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 1  # Set the priority for this rule

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }

  condition {
    host_header {
      values = [var.domain_name_frontend]
    }
  }
}

resource "aws_lb_listener_rule" "backend_https_domain_host_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 2  # Set the priority for this rule

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }

  condition {
    host_header {
      values = [var.domain_name_backend]
    }
  }
}
