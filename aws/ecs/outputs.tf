output "target_groups" {
  value = {
    for target_group in aws_lb_target_group.this : target_group.name => {
      arn = target_group.arn
    }
  }
}
