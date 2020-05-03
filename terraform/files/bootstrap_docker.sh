#!/bin/bash

sudo yum update -y
sudo yum install -y fail2ban
sudo amazon-linux-extras install -y docker
sudo service docker start
sudo systemctl enable docker
