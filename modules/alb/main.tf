# Application Load Balancer
resource "aws_lb" "main" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
  
  enable_deletion_protection = var.environment == "prod" ? true : false
  
  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "alb-logs"
    enabled = true
  }
  
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

# S3 Bucket for ALB Access Logs
resource "aws_s3_bucket" "lb_logs" {
  bucket = "${var.name}-logs-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name        = "${var.name}-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_acl" "lb_logs_acl" {
  bucket = aws_s3_bucket.lb_logs.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "lb_logs_lifecycle" {
  bucket = aws_s3_bucket.lb_logs.id
  
  rule {
    id     = "log-rotation"
    status = "Enabled"
    
    expiration {
      days = var.log_retention_days
    }
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# IAM Policy for ALB Logging
resource "aws_s3_bucket_policy" "allow_lb_logging" {
  bucket = aws_s3_bucket.lb_logs.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.current.id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.lb_logs.arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.lb_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.lb_logs.arn
      }
    ]
  })
}

# HTTP to HTTPS Redirect
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
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

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  
  default_action {
    type = "fixed-response"
    
    fixed_response {
      content_type = "text/plain"
      message_body = "No routing rule matched this request"
      status_code  = "404"
    }
  }
}

# Target Groups for Microservices
resource "aws_lb_target_group" "microservices" {
  for_each = { for tg in var.target_groups : tg.name => tg }
  
  name        = "${var.name}-${each.value.name}"
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    enabled             = true
    path                = each.value.health_check.path
    port                = "traffic-port"
    protocol            = each.value.protocol
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
  
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }
  
  tags = {
    Name        = "${var.name}-${each.value.name}"
    Environment = var.environment
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Listener Rules for Microservices
resource "aws_lb_listener_rule" "microservices" {
  for_each = { for tg in var.target_groups : tg.name => tg }
  
  listener_arn = aws_lb_listener.https.arn
  priority     = each.value.priority
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.microservices[each.key].arn
  }
  
  dynamic "condition" {
    for_each = each.value.host_header != null ? [1] : []
    content {
      host_header {
        values = [each.value.host_header]
      }
    }
  }
  
  dynamic "condition" {
    for_each = each.value.path_pattern != null ? [1] : []
    content {
      path_pattern {
        values = [each.value.path_pattern]
      }
    }
  }
}

# Data Sources
data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "current" {}

# Outputs
output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "alb_https_listener_arn" {
  description = "The ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
}

output "target_group_arns" {
  description = "Map of target group names to their ARNs"
  value = {
    for k, v in aws_lb_target_group.microservices : k => v.arn
  }
}

output "target_group_names" {
  description = "Map of target group names to their names"
  value = {
    for k, v in aws_lb_target_group.microservices : k => v.name
  }
}
