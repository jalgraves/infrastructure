resource "aws_alb" "jke_ingress" {
  name               = "jke-ingress"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = [aws_subnet.jalnet_ops.id, aws_subnet.jalnet_private_2b.id, aws_subnet.jalnet_private_2c.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = "beantown-alb-logs"
    enabled = false
  }

  tags = {
    region       = var.aws_region,
    aws-resource = "alb",
    provisioner  = "terraform"
  }
}

resource "aws_lb_target_group" "http" {
  name     = "beantown-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.prod.id
}

resource "aws_lb_target_group" "https" {
  name     = "beantown-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.prod.id
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.jke_ingress.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.ziggys_cert.arn

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
      values = ["rancher.ziggyscoffeebar.com"]
    }
  }
}

resource "aws_alb_target_group_attachment" "rancher" {
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = aws_instance.rancher01.id
  port             = 443
}
