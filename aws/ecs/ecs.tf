# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
resource "aws_ecs_cluster" "this" {
  # for_each = {
  #   for cluster_name, cluster in local.configs.clusters : cluster_name => cluster
  # }
  name = local.configs.environment
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "EcsTaskExecution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "secrets_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.secrets_policy.arn
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "services.internal"
  description = "Private namespace for ECS microservices"
  vpc         = aws_vpc.this.id
}

resource "aws_ecs_task_definition" "task" {
  for_each = local.services

  family                   = each.key
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = each.key
      image = each.value.image
      portMappings = [{
        containerPort = each.value.port
        hostPort      = each.value.port
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${each.key}"
          awslogs-region        = local.configs.region
          awslogs-stream-prefix = "ecs"
        }
      }
      secrets = try(each.value.secrets, [])
    }
  ])
}

resource "aws_service_discovery_service" "svc" {
  for_each = local.services

  name         = each.key
  namespace_id = aws_service_discovery_private_dns_namespace.this.id

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "WEIGHTED"
  }
}

resource "aws_ecs_service" "svc" {
  for_each        = local.services
  name            = each.key
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.task[each.key].arn
  launch_type     = "FARGATE"
  desired_count   = each.value.desired_count

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.endpoints.id]
    assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each = each.value.public ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.this[each.key].arn
      container_name   = each.key
      container_port   = each.value.port
    }
  }

  service_registries {
    registry_arn = aws_service_discovery_service.svc[each.key].arn
  }
}
