# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# resource "aws_lb_listener" "control_plane_public" {
#   count             = var.enabled ? 1 : 0
#   load_balancer_arn = var.nlb_public_arn
#   port              = var.api_port
#   protocol          = var.control_plane_protocol
#   certificate_arn   = var.certificate_arn
#   alpn_policy       = var.alpn_policy
#   default_action {
#     type             = "forward"
#     target_group_arn = one(aws_lb_target_group.control_plane_public[*].arn)
#   }
#   tags = {
#     Name = "${local.configs.cluster_name}-k8s-control-plane-public"
#   }
# }

# resource "aws_lb_listener" "control_plane_private" {
#   count             = var.enabled ? 1 : 0
#   load_balancer_arn = var.nlb_private_arn
#   port              = var.api_port
#   protocol          = var.control_plane_protocol
#   certificate_arn   = var.certificate_arn
#   alpn_policy       = var.alpn_policy
#   default_action {
#     type             = "forward"
#     target_group_arn = one(aws_lb_target_group.control_plane_private[*].arn)
#   }
#   tags = {
#     Name = "hks-api-${var.stage}-private"
#   }
# }

# resource "aws_lb_target_group" "control_plane_private" {
#   count              = var.enabled ? 1 : 0
#   name               = "k8s-control-plane-private"
#   port               = var.api_port
#   preserve_client_ip = var.preserve_client_ip_enabled
#   protocol           = var.control_plane_protocol
#   proxy_protocol_v2  = var.proxy_protocol_v2_enabled
#   target_type        = "instance"
#   vpc_id             = var.vpc_id
#   tags = {
#     Name = "${local.configs.cluster_name}-k8s-control-plane-private"
#   }
#   health_check {
#     healthy_threshold   = 2
#     protocol            = "TCP"
#     unhealthy_threshold = 2
#   }
# }

# resource "aws_lb_target_group" "control_plane_public" {
#   count              = var.enabled ? 1 : 0
#   name               = "k8-control-plane-public"
#   port               = var.api_port
#   preserve_client_ip = var.preserve_client_ip_enabled
#   protocol           = var.control_plane_protocol
#   proxy_protocol_v2  = var.proxy_protocol_v2_enabled
#   target_type        = "instance"
#   vpc_id             = var.vpc_id
#   tags = {
#     Name = "${local.configs.cluster_name}-k8s-control-plane-public"
#   }
# }



# resource "aws_lb_target_group_attachment" "control_plane_private" {
#   count            = var.enabled ? 1 : 0
#   target_group_arn = one(aws_lb_target_group.control_plane_private[*].arn)
#   target_id        = one(aws_instance.control_plane[*].id)
#   port             = var.api_port
# }

# resource "aws_lb_target_group_attachment" "control_plane_public" {
#   count            = var.enabled ? 1 : 0
#   target_group_arn = one(aws_lb_target_group.control_plane_public[*].arn)
#   target_id        = one(aws_instance.control_plane[*].id)
#   port             = var.api_port
# }
