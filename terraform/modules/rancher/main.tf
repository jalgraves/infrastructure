variable "vpc_id" {}
variable "name" { default = "rancher01" }
variable "security_group_id" {}
variable "subnet_id" {}
variable "block_size" {}

resource "aws_key_pair" "beantown_key" {
  key_name   = "beantown_aws"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+NHWRfQls4X59va1+fudUcOS5nDeFMbR495EO2T5AbPTjU1dmt6d0AKIGILDLdjOn1K4VHksUc9xEydD1er1CIPzHYx5iomRz2UEbgXiNrxSFA/XTevTkQFMI7ZwOAIMSqkWXr9OBvTylf5+jmEE0RVyPMs/b9nXevYN2CL0kzvoe3VeFXX3/+f4CWPjgnDhNY/Xm5YyUBUGTl1ZY+XlNl5ivTvZV0D6JoO/3Xj1aTykJ2rv1IScScTeQL7iq/E7szovfV0TqCKEyedbMBIeW3SURnZgyG8y7Z6jumraTd4N89Wl9qi1sE7pJquRe+ideoW23EJH33QO9PmAwn9h2OgEPcC4z6ZiUC5ZR2tIC/Wdzx4jyuY4/vUJgv/CUo60Clpg+8x73e3sO8aTvgrEHzX8RYMowddhEbd/kmeE7WG89QJdXCoxw6M/NnDbMLuwOp0lm1kZVdPnk/EggNq6gXgG7F+LARAxMJzyTEQ9foqJ4iU6mfsg5FfsnJTe1t/QA1ApwudWVqaOErX8Uso3MrgjHe3ctjW4kD3PiuuXYvJGUSeqn71MdwcKSxY9KN+F0d/BRb0W5S02zJvEUy3RwYd75YEoaF50Ag7xhkVx463ke08I86rHMmUYRvvFsaVqRtVVTqKebMYRkqpbw2TWF69IAehTMr5MYK5lPZ/oQfQ== jalgraves@gmail.com"
}

data "aws_subnet" "jalnet_public" {
  id = var.subnet_id
}

data "aws_vpc" "prod" {
  id = var.vpc_id
}

data "aws_security_group" "jal_default" {
  id = var.security_group_id
}

resource "aws_instance" "rancher01" {
  ami                    = lookup(var.aws_amis, var.aws_region)
  availability_zone      = var.node_azs["rancher01"]
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.beantown_key.id
  vpc_security_group_ids = [data.aws_security_group.jal_default.id]
  subnet_id              = data.aws_subnet.jalnet_public.id
  root_block_device {
    volume_type = "gp2"
    volume_size = var.block_size
  }

  connection {
    type        = "ssh"
    private_key = file("~/.ssh/beantown_aws_rsa")
    user        = "ec2-user"
    host        = coalesce(self.public_ip, self.private_ip)
  }

  provisioner "remote-exec" {
    # files dir is realative to root module
    script = "files/bootstrap_rancher.sh"
  }

  tags = {
    Name         = var.name
    role         = "rancher"
    region       = var.aws_region
    provisioner  = "terraform"
  }
}