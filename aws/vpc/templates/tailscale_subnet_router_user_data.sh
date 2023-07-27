#!/bin/bash
# shellcheck disable=SC2154
# shellcheck disable=SC2086

sudo yum update -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://pkgs.tailscale.com/stable/amazon-linux/2/tailscale.repo
sudo yum install -y tailscale

sudo systemctl enable --now tailscaled
sudo sed -i 's/^#Port 22/Port 3222/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

# enable ip forwarding for advertising subnets
# https://tailscale.com/kb/1023/troubleshooting#why-do-i-get-an-error-about-ip-forwarding-when-using-advertise-routes
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# https://tailscale.com/kb/1019/subnets
# sudo resolvectl default-route tailscale0 no
sudo tailscale up --authkey=${tailscale_auth_key} --advertise-routes=${subnets_to_advertise} --accept-dns=false
