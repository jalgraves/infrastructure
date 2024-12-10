# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# output "private_key" {
#   value     = tls_private_key.ec2_key.private_key_pem
#   sensitive = false
# }

# output "public_key" {
#   value = tls_private_key.ec2_key.public_key_openssh
# }

output "keys" {
  value = {
    for instance_name, instance in local.configs.instances : instance_name => {
      public  = nonsensitive(tls_private_key.ec2_key[instance_name].public_key_openssh)
      private = nonsensitive(tls_private_key.ec2_key[instance_name].private_key_openssh)
    }
  }
}

output "instances" {
  value = {
    for instance_name, instance in local.configs.instances : instance_name => aws_instance.this[instance_name]
  }
}
