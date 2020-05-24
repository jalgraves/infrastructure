output "instance_id" {
  value = aws_instance.rancher01.id
}

output "instance_ip" {
  value = aws_instance.rancher01.public_ip
}