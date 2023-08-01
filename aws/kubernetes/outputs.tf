output "k8s_control_plane" {
  value = aws_instance.k8s_control_plane.private_ip
}
