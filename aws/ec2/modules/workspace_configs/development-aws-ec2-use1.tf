# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# Configs specific to the workspace development-aws-iam-use1

locals {
  development-aws-ec2-use1 = {
    availability_zone  = "us-east-1a"
    cluster_name       = "development-use1"
    environment        = "development"
    region             = "us-east-1"
    region_code        = "use1"
    remote_bucket_name = "development-use1-terraform-remote-state-ibay8n2u"
    instances = {
      # iam_instance_profile for an instance first needs to be created in the aws/iam directory
      control-plane = {
        associate_public_ip_address = true
        external_dns_domain         = "development.use1.jalgraves.com"
        http_endpoint               = "enabled"
        iam_instance_profile        = "DevelopmentUse1K8sControlPlane"
        instance_type               = "t3a.large"
        root_block_device = {
          encrypted   = true
          volume_size = 50
          volume_type = "gp3"
        }
        user_data_script            = "kubernetes_install.sh"
        user_data_replace_on_change = true
      }
    }
  }
}
