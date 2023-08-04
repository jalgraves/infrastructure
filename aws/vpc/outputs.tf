# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "vpc" {
  value = {
    id = aws_vpc.this.id
  }
}

output "subnets" {
  value = {
    public = {
      ids = aws_subnet.public[*].id
      ipv4 = {
        bits  = local.bits
        cidrs = aws_subnet.public[*].cidr_block
      }
      ipv6 = {
        cidrs = aws_subnet.public[*].ipv6_cidr_block
      }
    }
    private = {
      ids = aws_subnet.private[*].id
      ipv4 = {
        cidrs = aws_subnet.private[*].cidr_block
      }
      ipv6 = {
        cidrs = aws_subnet.private[*].ipv6_cidr_block
      }
    }
  }
}

output "tailscale" {
  value = {
    key_pair = {
      id   = aws_key_pair.tailscale[0].id
      name = aws_key_pair.tailscale[0].key_name
    }
    security_group = {
      id = aws_security_group.tailscale[0].id
    }
  }
}
