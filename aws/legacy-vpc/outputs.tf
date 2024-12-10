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
    availability_zones = local.configs.availability_zones
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
      id   = aws_key_pair.tailscale.id
      name = aws_key_pair.tailscale.key_name
    }
    public_ssh_key = aws_key_pair.tailscale.public_key
    public_ip      = aws_instance.tailscale_subnet_router[0].public_ip
    security_group = {
      id = aws_security_group.tailscale[0].id
    }
  }
}

output "packer" {
  value = {
    role = {
      arn = aws_iam_role.packer.arn
    }
    instance_profile = aws_iam_instance_profile.packer
  }
}
