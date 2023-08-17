# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_launch_template" "kubernetes_cluster_autoscaler" {
  ebs_optimized = true
  image_id      = "ami-0e41cfec46a3cd220"
  key_name      = data.tfe_outputs.vpc.values.tailscale.key_pair.name
  name          = "kubernetes-cluster-autoscaler"
  user_data     = base64encode(local.join_user_data)
  vpc_security_group_ids = [
    aws_security_group.internal_traffic.id,
    aws_security_group.k8s_control_plane.id,
    data.tfe_outputs.vpc.values.tailscale.security_group.id
  ]

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

  instance_market_options {
    market_type = "spot"
  }
  instance_requirements {
    allowed_instance_types = [
      "t3a.medium",
      "t3a.large"
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
      on_demand_percentage_above_base_capacity = 25
      spot_allocation_strategy                 = "capacity-optimized"
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.kubernetes_cluster_autoscaler.id
      }
    }
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/production-use2"
    value               = local.configs.cluster_name
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/role"
    value               = "worker"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

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

locals {
  join_template_vars = {
    api_server_endpoint = var.control_plane_endpoint
    api_server_port     = var.api_port
    cluster_name        = local.configs.cluster_name
    region              = local.configs.region
    region_code         = local.configs.region_code
  }
  join_user_data = templatefile("${path.module}/templates/join_cluster.sh", local.join_template_vars)
}
