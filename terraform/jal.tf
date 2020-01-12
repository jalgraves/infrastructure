provider "aws" {
    profile = "default"
    region  = var.aws_region
}

resource "aws_instance" "rancher01" {
    ami                    = lookup(var.aws_amis, var.aws_region)
    availability_zone      = "us-east-2a"
    instance_type          = "t2.small"
    key_name               = "jal_aws"
    vpc_security_group_ids = [aws_security_group.jal_default.id]
    subnet_id              = aws_subnet.jal_subnet_public_2a.id
    ebs_block_device {
        device_name = "/dev/xvda"
        volume_type = "gp2"
        volume_size = 10
    }
    connection {
        type        = "ssh"
        private_key = file("~/.ssh/jal_aws_rsa")
        user        = "ec2-user"
        host        = self.public_ip
    }
    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
            "sudo yum install -y certbot",
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
    key_name               = "jal_aws"
    vpc_security_group_ids = [aws_security_group.jal_default.id]
    subnet_id              = aws_subnet.jal_subnet_public_2a.id
    ebs_block_device {
        device_name = "/dev/xvda"
        volume_type = "gp2"
        volume_size = 15
    }
    connection {
        type        = "ssh"
        private_key = file("~/.ssh/jal_aws_rsa")
        user        = "ec2-user"
        host        = self.public_ip
    }
    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
            "sudo yum install -y certbot",
            "sudo amazon-linux-extras install -y docker",
            "sudo service docker start",
            "sudo systemctl enable docker"
        ]
    }
    tags = {
        Name         = "jke-control01"
        jke/role     = "k8s-control"
        region       = var.aws_region
        aws-resource = "instance"
        provisioner  = "terraform"
    }
}

resource "aws_instance" "jke_worker01" {
    availability_zone      = "us-east-2a"
    ami                    = lookup(var.aws_amis, var.aws_region)
    instance_type          = "t2.small"
    key_name               = "jal_aws"
    vpc_security_group_ids = [aws_security_group.jal_default.id]
    subnet_id              = aws_subnet.jal_subnet_public_2a.id
    ebs_block_device {
        device_name = "/dev/xvda"
        volume_type = "gp2"
        volume_size = 50
    }
    connection {
        type        = "ssh"
        private_key = file("~/.ssh/jal_aws_rsa")
        user        = "ec2-user"
        host        = self.public_ip
    }
    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
            "sudo yum install -y certbot",
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
