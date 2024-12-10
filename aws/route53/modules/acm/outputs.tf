# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |H|Q|O| |D|E|V|O|P|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+

output "certificate" {
  value = {
    arn         = aws_acm_certificate.this.arn
    domain_name = aws_acm_certificate.this.domain_name
    name        = var.name
  }
}
