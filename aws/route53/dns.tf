# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_route53_zone" "aws" {
  name = "aws.${local.configs.org}.com"
}

resource "aws_route53_zone" "region" {
  comment = "Zone for creating records that will point to ${local.configs.org} services running in K8s clusters. Managed via Terraform TFC workspace ${terraform.workspace}"
  name    = "${local.configs.region_code}.aws.${local.configs.org}.com"
  tags    = {}
}


resource "aws_route53_zone" "env" {
  comment = "Zone for creating records that will point to ${local.configs.org} K8s clusters. Managed via Terraform TFC workspace ${terraform.workspace}"
  name    = "${local.configs.env}.${local.configs.region_code}.aws.${local.configs.org}.com"
  tags    = {}
}

resource "aws_route53_record" "env" {
  zone_id = aws_route53_zone.region.zone_id
  name    = "${local.configs.env}.${local.configs.region_code}.aws.${local.configs.org}.com"
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.env.name_servers
}

resource "aws_route53_record" "region" {
  zone_id = data.aws_route53_zone.aws.zone_id
  name    = "${local.configs.region_code}.aws.${local.configs.org}.com"
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.region.name_servers
}
