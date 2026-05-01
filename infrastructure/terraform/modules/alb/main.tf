resource "aws_security_group" "alb_public" {
  name        = "shopcloud-alb-public-${var.env}"
  description = "Security group for public ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "shopcloud-alb-public-${var.env}"
    Env  = var.env
  }
}

resource "aws_security_group" "alb_internal" {
  name        = "shopcloud-alb-internal-${var.env}"
  description = "Security group for internal ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "shopcloud-alb-internal-${var.env}"
    Env  = var.env
  }
}

# Public ALB for customer-facing services
resource "aws_lb" "public" {
  name               = "shopcloud-public-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_public.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.env == "prod"

  tags = {
    Name = "shopcloud-public-${var.env}"
    Env  = var.env
  }
}

# Internal ALB for admin service
resource "aws_lb" "internal" {
  name               = "shopcloud-internal-${var.env}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_internal.id]
  subnets            = var.private_subnet_ids

  enable_deletion_protection = var.env == "prod"

  tags = {
    Name = "shopcloud-internal-${var.env}"
    Env  = var.env
  }
}

# Target groups for customer services
resource "aws_lb_target_group" "services" {
  for_each = var.services

  name        = "shopcloud-${each.key}-${var.env}"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 30
    path                = each.value.health_check_path
    matcher             = "200"
  }

  tags = {
    Name = "shopcloud-${each.key}-${var.env}"
    Env  = var.env
  }
}

# Target group for admin service
resource "aws_lb_target_group" "admin" {
  name        = "shopcloud-admin-${var.env}"
  port        = 3005
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Name = "shopcloud-admin-${var.env}"
    Env  = var.env
  }
}

# Public ALB listener - redirect HTTP to HTTPS
resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Public ALB listener - HTTPS (if enabled) or HTTP direct for dev
resource "aws_lb_listener" "public_https" {
  load_balancer_arn = aws_lb.public.arn
  port              = 443
  protocol          = var.enable_ssl ? "HTTPS" : "HTTP"
  certificate_arn   = var.enable_ssl ? var.certificate_arn : null

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# Listener rule for auth service
resource "aws_lb_listener_rule" "auth" {
  listener_arn = aws_lb_listener.public_https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["auth"].arn
  }

  condition {
    path_pattern {
      values = ["/auth*"]
    }
  }
}

# Listener rule for catalog service
resource "aws_lb_listener_rule" "catalog" {
  listener_arn = aws_lb_listener.public_https.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["catalog"].arn
  }

  condition {
    path_pattern {
      values = ["/catalog*", "/products*", "/categories*"]
    }
  }
}

# Listener rule for cart service
resource "aws_lb_listener_rule" "cart" {
  listener_arn = aws_lb_listener.public_https.arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["cart"].arn
  }

  condition {
    path_pattern {
      values = ["/cart*"]
    }
  }
}

# Listener rule for checkout service
resource "aws_lb_listener_rule" "checkout" {
  listener_arn = aws_lb_listener.public_https.arn
  priority     = 4

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["checkout"].arn
  }

  condition {
    path_pattern {
      values = ["/checkout*", "/orders*"]
    }
  }
}

# Listener rule for invoice service
resource "aws_lb_listener_rule" "invoice" {
  listener_arn = aws_lb_listener.public_https.arn
  priority     = 5

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["invoice"].arn
  }

  condition {
    path_pattern {
      values = ["/invoice*"]
    }
  }
}

# Internal ALB listener for admin service
resource "aws_lb_listener" "internal" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.admin.arn
  }
}
