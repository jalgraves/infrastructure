# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+


output "identities" {
  value = {
    for identity_name, identity in local.configs.identities : identity_name => {
      arn  = aws_sesv2_email_identity.this[identity_name].arn
      dkim = nonsensitive(aws_sesv2_email_identity.this[identity_name].dkim_signing_attributes[0].tokens)
    }
  }
}
