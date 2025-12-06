# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+

resource "aws_cloudwatch_log_group" "ecs" {
  for_each = local.services

  name              = "/ecs/${each.key}"
  retention_in_days = 7

  tags = {
    Name = "/ecs/${each.key}"
  }
}
