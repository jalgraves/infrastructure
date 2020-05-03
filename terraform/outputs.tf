output "alb_address" {
  value = aws_alb.jke_ingress.dns_name
}