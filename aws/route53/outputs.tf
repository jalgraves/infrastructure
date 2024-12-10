# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "acm" {
  # Certificate output is exported for other Terraform workspaces to consume.
  value = {
    certificates = {
      for cert in module.acm : cert.certificate.name => {
        arn = cert.certificate.arn
      }
    }
  }
}

output "parent_zones" {
  value = local.dns
}

output "dns" {
  description = <<EOF
    These outputs are used by other workspaces to create DNS records for the
    resources they're managing. For example each ec2 workspace uses the outputs
    from the zones created to pass the domains to exteranl-dns so DNS records
    can automatically be created to point at our apps running in K8s clusters.
  EOF
  value = {
    zones = {
      # These zones are used by other Terraform workspaces when creating DNS records
      # for specific AWS resources like a database or Redis cache
      for zone in aws_route53_zone.this : zone.name => {
        arn          = zone.arn
        name_servers = zone.name_servers
        id           = zone.id
        parent_zone = {
          name = local.dns[zone.name].parent_zone
          id   = aws_route53_zone.this[local.dns[zone.name].parent_zone].id
        }
      }
    }
    records = {
      for record in aws_route53_record.nameservers : record.name => {
        id           = record.id
        name_servers = record.records
        zone_id      = record.zone_id
      }
    }
  }
}
