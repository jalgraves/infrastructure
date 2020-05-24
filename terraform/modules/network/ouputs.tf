output "prod_vpc_id" {
  value       = aws_vpc.prod.id
  description = "The ID of the prod VPC"
}

output "jalnet_public_subnet_id" {
  value = aws_subnet.jalnet_public.id
}

output "jalnet_private_subnet_2b_id" {
  value = aws_subnet.jalnet_private_2b.id
}

output "jalnet_private_subnet_2c_id" {
  value = aws_subnet.jalnet_private_2c.id
}

output "alb_sg_id" {
  value = aws_security_group.load_balancer.id
}

output "jal_sg_id" {
  value = aws_security_group.jal_default.id
}

output "prod_vpc_arn" {
  value       = aws_vpc.prod.arn
  description = "The ARN of the prod VPC"
}

output "subnet_ids" {
  value = [aws_subnet.jalnet_public.id, aws_subnet.jalnet_private_2b.id, aws_subnet.jalnet_private_2c.id]
}