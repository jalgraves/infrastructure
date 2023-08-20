# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_iam_user" "kubernetes_cluster_autoscaler" {
  # Automated user for kubernetes cluster autoscaler
  name = "kubernetes-cluster-autoscaler"
  path = "/system/"
}

resource "aws_iam_user_policy" "kubernetes_cluster_autoscaler" {
  name = "KubernetesClusterAutoscaler"
  user = aws_iam_user.kubernetes_cluster_autoscaler.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeImages",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "kubernetes_cluster_autoscaler" {
  user   = aws_iam_user.kubernetes_cluster_autoscaler.id
  status = "Active"
}

data "aws_ami" "worker_node" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${local.configs.env}*"]
  }
}

locals {
  join_template_vars = {
    api_server_endpoint = var.control_plane_endpoint
    api_server_port     = var.api_port
    secret_name         = aws_secretsmanager_secret.cluster.name
    region              = local.configs.region
    region_code         = local.configs.region_code
  }
  join_user_data = templatefile("${path.module}/templates/join_cluster.sh", local.join_template_vars)
}

resource "aws_launch_template" "kubernetes_cluster_autoscaler" {
  ebs_optimized = true
  image_id      = data.aws_ami.worker_node.id
  key_name      = data.tfe_outputs.vpc.values.tailscale.key_pair.name
  name_prefix   = "${local.configs.cluster_name}-k8s-ca-"
  user_data     = base64encode(local.join_user_data)
  #instance_type = "t3.medium"
  vpc_security_group_ids = [
    aws_security_group.internal_traffic.id,
    aws_security_group.k8s_control_plane.id,
    data.tfe_outputs.vpc.values.tailscale.security_group.id
  ]
  tags = {
    Name = "${local.configs.cluster_name}-k8s-ca"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 750
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = module.iam.k8s_worker.instance_profile.name
  }

  instance_requirements {
    allowed_instance_types = [
      "t2.medium",
      "t2.large",
      "t3.medium",
      "t3.large",
      "t3a.medium",
      "t3a.large",
      "m4.large",
      "m5.large",
      "m5a.large"
    ]
    memory_mib {
      min = 400
    }
    vcpu_count {
      min = 2
    }
  }

  metadata_options {
    http_endpoint = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.configs.cluster_name}-k8s-worker"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "kubernetes_cluster_autoscaler" {
  name_prefix         = "${local.configs.cluster_name}-k8s-"
  max_size            = 2
  min_size            = 0
  desired_capacity    = 0
  force_delete        = true
  vpc_zone_identifier = data.tfe_outputs.vpc.values.subnets.private.ids

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "price-capacity-optimized"
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.kubernetes_cluster_autoscaler.id
        version            = aws_launch_template.kubernetes_cluster_autoscaler.latest_version
      }
    }
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${local.configs.cluster_name}}"
    value               = local.configs.cluster_name
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/role"
    value               = "worker"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      desired_capacity,
      max_size,
      min_size
    ]
    create_before_destroy = true
  }
}
