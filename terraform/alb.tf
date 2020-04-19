resource "aws_lb" "jke_ingress" {
    name               = "jke-ingress"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.load_balancer.id]
    subnets            = [aws_subnet.jal_subnet_public_2a.id, aws_subnet.jal_subnet_public.id]

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
    protocol = "HTTP"
    vpc_id   = aws_vpc.prod.id
}

resource "aws_acm_certificate" "ziggys_cert" {
    domain_name       = "*.ziggyscoffeebar.com"
    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

data "aws_route53_zone" "ziggys_zone" {
    name         = "ziggyscoffeebar.com."
    private_zone = false
}

resource "aws_route53_record" "cert_validation" {
    name    = aws_acm_certificate.ziggys_cert.domain_validation_options.0.resource_record_name
    type    = aws_acm_certificate.ziggys_cert.domain_validation_options.0.resource_record_type
    zone_id = data.aws_route53_zone.ziggys_zone.id
    records = [aws_acm_certificate.ziggys_cert.domain_validation_options.0.resource_record_value]
    ttl     = 60
}

resource "aws_acm_certificate_validation" "ziggys_cert" {
    certificate_arn         = aws_acm_certificate.ziggys_cert.arn
    validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

resource "aws_alb_listener" "front_end" {
    load_balancer_arn = aws_lb.jke_ingress.arn
    port              = "443"
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = aws_acm_certificate.ziggys_cert.arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.https.arn
    }
}
