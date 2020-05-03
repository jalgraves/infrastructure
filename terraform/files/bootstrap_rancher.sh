#!/bin/bash

RANCHER_VERSION=v2.4.2
LOG_DRIVER='{"log-driver": "json-file","log-opts": {"max-size": "100m", "max-file": "7"}}'

sudo yum update -y
sudo yum install -y jq fail2ban
sudo amazon-linux-extras install -y docker

echo ${LOG_DRIVER} | jq . > daemon.json

sudo mv daemon.json /etc/docker/
sudo service docker start
sudo systemctl enable docker

sudo docker run \
    -d \
    -p 80:80 \
    -p 443:443 \
    --restart=unless-stopped \
    --name rancher_server \
    --log-opt max-size=100m \
    --log-opt max-file=7 \
    rancher/rancher:${RANCHER_VERSION}
