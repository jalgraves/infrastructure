# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "organization_id" {
  value = aws_organizations_organization.this.id
}

output "organization_units" {
  value = {
    for ou_name, ou in local.organizational_units : ou_name => {
      id = aws_organizations_organizational_unit.parent[ou_name].id
    }
  }
}
