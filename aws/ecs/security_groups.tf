# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+

resource "aws_security_group" "endpoints" {
  name   = "${local.configs.environment}-vpc-endpoints"
  vpc_id = aws_vpc.this.id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [local.vpc_cidr]
  }

  # Allow ALB to reach ECS tasks on application ports
  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 9000
    security_groups = [aws_security_group.alb.id]
    description     = "Allow ALB to reach ECS tasks"
  }

  # Allow ECS tasks to communicate with each other (e.g., menu-api to psql)
  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    self        = true
    description = "Allow PostgreSQL connections between ECS tasks"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 5004
    to_port     = 5004
    self        = true
    description = "Allow Menu API connections between ECS tasks"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 5012
    to_port     = 5012
    self        = true
    description = "Allow Contact API connections between ECS tasks"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  endpoints = [
    "ecr.api",
    "ecr.dkr",
    "ecs",
    "ecs-agent",
    "ecs-telemetry",
    "logs"
  ]
}

resource "aws_security_group" "alb" {
  name   = "${local.configs.environment}-alb"
  vpc_id = aws_vpc.this.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
