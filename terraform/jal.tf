provider "aws" {
    profile = "beantown"
    region  = var.aws_region
}

resource "aws_key_pair" "beantown_key" {
    key_name   = "beantown_aws"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+NHWRfQls4X59va1+fudUcOS5nDeFMbR495EO2T5AbPTjU1dmt6d0AKIGILDLdjOn1K4VHksUc9xEydD1er1CIPzHYx5iomRz2UEbgXiNrxSFA/XTevTkQFMI7ZwOAIMSqkWXr9OBvTylf5+jmEE0RVyPMs/b9nXevYN2CL0kzvoe3VeFXX3/+f4CWPjgnDhNY/Xm5YyUBUGTl1ZY+XlNl5ivTvZV0D6JoO/3Xj1aTykJ2rv1IScScTeQL7iq/E7szovfV0TqCKEyedbMBIeW3SURnZgyG8y7Z6jumraTd4N89Wl9qi1sE7pJquRe+ideoW23EJH33QO9PmAwn9h2OgEPcC4z6ZiUC5ZR2tIC/Wdzx4jyuY4/vUJgv/CUo60Clpg+8x73e3sO8aTvgrEHzX8RYMowddhEbd/kmeE7WG89QJdXCoxw6M/NnDbMLuwOp0lm1kZVdPnk/EggNq6gXgG7F+LARAxMJzyTEQ9foqJ4iU6mfsg5FfsnJTe1t/QA1ApwudWVqaOErX8Uso3MrgjHe3ctjW4kD3PiuuXYvJGUSeqn71MdwcKSxY9KN+F0d/BRb0W5S02zJvEUy3RwYd75YEoaF50Ag7xhkVx463ke08I86rHMmUYRvvFsaVqRtVVTqKebMYRkqpbw2TWF69IAehTMr5MYK5lPZ/oQfQ== jalgraves@gmail.com"
}

resource "aws_instance" "rancher01" {
    ami                    = lookup(var.aws_amis, var.aws_region)
    availability_zone      = "us-east-2a"
    instance_type          = "t2.small"
    key_name               = aws_key_pair.beantown_key.id
    vpc_security_group_ids = [aws_security_group.jal_default.id]
    subnet_id              = aws_subnet.jal_subnet_public_2a.id
    ebs_block_device {
        device_name = "/dev/xvda"
        volume_type = "gp2"
        volume_size = 10
    }
    connection {
        type        = "ssh"
        private_key = file("~/.ssh/beantown_aws_rsa")
        user        = "ec2-user"
        host        = self.public_ip
    }
    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
            "sudo yum install -y certbot fail2ban",
            "sudo amazon-linux-extras install -y docker",
            "sudo service docker start",
            "sudo systemctl enable docker"
        ]
    }
    tags = {
        Name         = "rancher01"
        role         = "rancher"
        region       = var.aws_region
        aws-resource = "instance"
        provisioner  = "terraform"
    }
}

resource "aws_instance" "jke_control01" {
    availability_zone      = "us-east-2a"
    ami                    = lookup(var.aws_amis, var.aws_region)
    instance_type          = "t2.micro"
    key_name               = aws_key_pair.beantown_key.id
    vpc_security_group_ids = [aws_security_group.jal_default.id]
    subnet_id              = aws_subnet.jal_subnet_public_2a.id
    ebs_block_device {
        device_name = "/dev/xvda"
        volume_type = "gp2"
        volume_size = 15
    }
    connection {
        type        = "ssh"
        private_key = file("~/.ssh/beantown_aws_rsa")
        user        = "ec2-user"
        host        = self.public_ip
    }
    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
            "sudo yum install -y fail2ban",
            "sudo amazon-linux-extras install -y docker",
            "sudo service docker start",
            "sudo systemctl enable docker"
        ]
    }
    tags = {
        Name         = "jke-control01"
        role         = "k8s-control"
        region       = var.aws_region
        aws-resource = "instance"
        provisioner  = "terraform"
    }
}

resource "aws_instance" "jke_worker01" {
    availability_zone      = "us-east-2a"
    ami                    = lookup(var.aws_amis, var.aws_region)
    instance_type          = "t2.small"
    key_name               = aws_key_pair.beantown_key.id
    vpc_security_group_ids = [aws_security_group.jal_default.id]
    subnet_id              = aws_subnet.jal_subnet_public_2a.id
    ebs_block_device {
        device_name = "/dev/xvda"
        volume_type = "gp2"
        volume_size = 50
    }
    connection {
        type        = "ssh"
        private_key = file("~/.ssh/beantown_aws_rsa")
        user        = "ec2-user"
        host        = self.public_ip
    }
    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
            "sudo yum install -y fail2ban",
            "sudo amazon-linux-extras install -y docker",
            "sudo service docker start",
            "sudo systemctl enable docker"
        ]
    }
    tags = {
        Name         = "jke-worker01"
        role         = "jke-worker"
        region       = var.aws_region
        aws-resource = "instance"
        provisioner  = "terraform"
    }
}
