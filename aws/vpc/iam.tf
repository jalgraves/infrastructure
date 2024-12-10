# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# resource "aws_iam_role" "packer" {
#   name = "${title(local.configs.env)}${title(local.configs.region_code)}Packer"
#   path = "/"
#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Sid" : "",
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : [
#             "ec2.amazonaws.com"
#           ]
#         },
#         "Action" : "sts:AssumeRole"
#       }
#     ]
#   })
#   tags = {
#     "Name" = "${title(local.configs.env)}${title(local.configs.region_code)}Packer"
#   }
# }

# resource "aws_iam_instance_profile" "packer" {
#   name = "${title(local.configs.env)}${title(local.configs.region_code)}Packer"
#   role = aws_iam_role.packer.name
# }

# resource "aws_iam_role_policy_attachment" "packer_admin" {
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
#   role       = aws_iam_role.packer.name
# }
