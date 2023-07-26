# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "vpc" {
  value = {
    id = aws_vpc.this.id
  }
}

output subnets {
  value  = {
    public ={
      ids = aws_subnet.public[*].id
      ipv4 = {
        cidrs = aws_subnet.public[*].cidr_block
      }
      ipv6 = {
        cidrs = aws_subnet.public[*].ipv6_cidr_block
      }
    }
    private ={
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

output "aws_vpc_ipam" {
  value = aws_vpc_ipam.this
}
