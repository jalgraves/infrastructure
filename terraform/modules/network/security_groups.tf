resource "aws_security_group" "load_balancer" {
  name        = "load_balancer_sg"
  description = "Security group for load balancer"
  vpc_id      = aws_vpc.prod.id

  ingress {
    description = "HTTP access from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS access from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP access from my IP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["72.74.95.20/32"]
  }

  egress {
    description = "Outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "jal_default" {
  name        = "jal_default_sg"
  description = "JAL security group"
  vpc_id      = aws_vpc.prod.id

  ingress {
    description = "SSH access from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["72.74.95.20/32"]
  }

  ingress {
    description = "HTTP access from the VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "HTTPS access from ALB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  ingress {
    description = "TCP access from the VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "TCP access from my IP"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["72.74.95.20/32"]
  }

  egress {
    description = "Outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}