variable "aws_region" {}
variable "vpc_id" {}
variable "security_group_id" {}
variable subnets {}
variable "instance_id" {
  type = any
  default = null
}

data "aws_subnet_ids" "all" {
  vpc_id = var.vpc_id
}

resource "aws_acm_certificate" "jalgraves_dev" {
  domain_name       = "*.dev.jalgraves.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb" "jke_ingress" {
  name               = "jke-ingress"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnets

  enable_deletion_protection = false

  access_logs {
    bucket  = "beantown-alb-logs"
    enabled = false
  }

  tags = {
    Name         = "rancher-alb",
    region       = var.aws_region,
    provisioner  = "terraform"
  }
}

resource "aws_lb_target_group" "http" {
  name     = "beantown-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "https" {
  name     = "beantown-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.jke_ingress.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.jalgraves_dev.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_listener_rule" "rancher" {
  listener_arn = aws_alb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }

  condition {
    host_header {
      values = ["rancher.jalgraves.com", "rancher.dev.jalgraves.com"]
    }
  }
}

resource "aws_alb_target_group_attachment" "rancher" {
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = var.instance_id
  port             = 443
  depends_on = [var.instance_id]
}
