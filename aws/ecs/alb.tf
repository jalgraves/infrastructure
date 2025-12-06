# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+

# Data source to look up ACM certificate by domain
# Alternative: Use a variable for certificate_arn if you prefer
data "aws_acm_certificate" "this" {
  for_each = {
    for service_name, service in local.services : service_name => service if service.public
  }
  domain      = each.value.certificate_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_lb" "public" {
  name               = "${local.configs.environment}-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
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

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.public.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = "arn:aws:acm:us-east-1:286957628288:certificate/04beae04-d71b-460a-b84c-9f9a5b970929"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_certificate" "this" {
  for_each = {
    for service_name, service in local.services : service_name => service if service.public
  }
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = data.aws_acm_certificate.this[each.key].arn
}

resource "aws_lb_target_group" "this" {
  for_each    = { for k, v in local.services : k => v if v.public }
  name        = "${local.configs.environment}-${each.key}"
  port        = each.value.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = each.value.healthcheck
    protocol            = "HTTP"
    matcher             = "200"
  }
}

locals {
  domains = {
    beantownpub     = ["beantownpub.com", "www.beantownpub.com"]
    contact-api     = ["contact-api.beantownpub.com"]
    drdavisicecream = ["drdavisicecream.com", "www.drdavisicecream.com"]
    menu-api        = ["menu-api.beantownpub.com"]
    thehubpub       = ["thehubpub.com", "www.thehubpub.com"]
    wavelengths     = ["wavelengths-brookline.com", "www.wavelengths-brookline.com"]
  }
}

resource "aws_lb_listener_rule" "http_rule" {
  for_each     = aws_lb_target_group.this
  listener_arn = aws_lb_listener.http.arn
  priority     = 10 + index(keys(aws_lb_target_group.this), each.key)

  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      # You can use wildcards like *.example.com to match any subdomain
      # Examples:
      # - "*.beantownpub.com" matches api.beantownpub.com, www.beantownpub.com, etc.
      # - "beantownpub.com" matches only the exact domain
      # - "*" matches any host (use with caution)
      values = local.domains[each.key]
    }
  }
}

resource "aws_lb_listener_rule" "https_rule" {
  for_each     = aws_lb_target_group.this
  listener_arn = aws_lb_listener.https.arn
  priority     = 10 + index(keys(aws_lb_target_group.this), each.key)

  action {
    type             = "forward"
    target_group_arn = each.value.arn
  }

  condition {
    host_header {
      values = local.domains[each.key]
    }
  }
}
