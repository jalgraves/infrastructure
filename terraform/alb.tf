resource "aws_lb" "jke_ingress" {
    name               = "jke-ingress"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.load_balancer.id]
    subnets            = [aws_subnet.jal_subnet_public_2a.id, aws_subnet.jal_subnet_public.id]

    enable_deletion_protection = false

    access_logs {
        bucket  = "jke-ingress-alb-logs"
        enabled = true
    }

    tags = {
        region       = vars.aws_region,
        aws-resource = "alb",
        provisioner  = "terraform"
    }
}