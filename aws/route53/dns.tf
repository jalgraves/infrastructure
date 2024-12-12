# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  dns = {
    for zone in keys(local.configs.dns.zones) : zone => {
      parent_zone = (
        length(split(".", zone)) > 2 && contains(split(".", zone), "uk") == false ?
        join(".", slice(split(".", zone), 1, length(split(".", zone)))) :
        zone
      )
    }
  }
}


resource "aws_route53_zone" "this" {
  for_each = {
    for zone in keys(local.configs.dns.zones) : zone => zone
  }
  comment = "Managed via Terraform workspace ${terraform.workspace}"
  name    = each.value
  tags = {
    Name = each.value
  }
}

resource "aws_route53_record" "nameservers" {
  # Delegates DNS aurthority to subdomains. For example, this will add the NS records for
  # the zone use1.jalgraves.com to the zone jalgraves.com so that the subdomain
  # (use1.jalgraves.com) can act as its own zone. This allows DNS record creation to
  # occur across individual subdomains instead of bloating the root zone with all the records
  for_each = {
    for zone in keys(local.configs.dns.zones) : zone => zone
    if length(split(".", zone)) > 2
  }
  zone_id = aws_route53_zone.this[try(local.configs.dns.zones[each.value].parent_zone, local.dns[each.value].parent_zone)].zone_id

  name    = each.value
  type    = "NS"
  ttl     = "3600"
  records = aws_route53_zone.this[each.value].name_servers
}

resource "aws_route53_record" "this" {
  for_each = {
    for item in flatten([
      for zone_name, zone in local.configs.dns.zones : [
        for record in zone.records : {
          name      = try(record.name, aws_route53_zone.this[zone_name].name)
          records   = record.records
          ttl       = try(record.ttl, local.configs.dns.common_ttl)
          type      = record.type
          zone_name = zone_name
        }
      ]
    ])
    # Here we name the object meaning that the created resources output will be available
    # at aws_route53_record.this[<object name>]. The <object name> will be made up of the
    # type of DNS record and the FQDN of the domain. Example aws_route53_record.this["MX:jalgraves.com"]
    # Another would aws_route53_record.this["CNAME:mail.jalgraves.com"]
    # The below ternary ensures that we don't have duplicate names in the <object name>.
    : "${item.type}:${item.name == item.zone_name ? item.name : "${item.name}.${item.zone_name}"}" => item
  }
  zone_id = aws_route53_zone.this[each.value.zone_name].zone_id
  name    = each.value.name
  type    = each.value.type
  records = each.value.records
  ttl     = each.value.ttl
}
