locals {
  production-use1-ecs = {
    environment = "production"
    region      = "us-east-1"
    region_code = "use1"
    clusters = {
      production = {
        roles = {
          EcsTaskExecution = {
            policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
          }
        }
      }
    }
  }
}
