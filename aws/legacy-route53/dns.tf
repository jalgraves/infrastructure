# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_route53_zone" "aws" {
  name = "aws.${local.legacy_configs.org}.com"
}

resource "aws_route53_zone" "region" {
  comment = "Zone for creating records that will point to ${local.legacy_configs.org} services running in K8s clusters. Managed via Terraform TFC workspace ${terraform.workspace}"
  name    = "${local.legacy_configs.region_code}.${local.legacy_configs.env}.aws.${local.legacy_configs.org}.com"
  tags    = {}
}


resource "aws_route53_zone" "env" {
  comment = "Zone for creating records that will point to ${local.legacy_configs.org} K8s clusters. Managed via Terraform TFC workspace ${terraform.workspace}"
  name    = "${local.legacy_configs.env}.aws.${local.legacy_configs.org}.com"
  tags    = {}
}

resource "aws_route53_record" "env" {
  zone_id = data.aws_route53_zone.aws.zone_id
  name    = "${local.legacy_configs.env}.aws.${local.legacy_configs.org}.com"
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.env.name_servers
}

resource "aws_route53_record" "region" {
  zone_id = aws_route53_zone.env.zone_id
  name    = "${local.legacy_configs.region_code}.${local.legacy_configs.env}.aws.${local.legacy_configs.org}.com"
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.region.name_servers
}
