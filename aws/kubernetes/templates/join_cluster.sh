#!/bin/bash

# disable shellcheck for terraform template vars
# shellcheck disable=SC2154
# shellcheck disable=SC2086
# shellcheck disable=SC2034
# shellcheck disable=SC2193
# shellcheck disable=SC2182
# shellcheck disable=SC2059
# Log output available on instance in /var/log/cloud-init-output.log

sudo su -
swapoff -a
yum update -y
yum install -y iproute-tc bind-utils jq nmap git

cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
amazon-linux-extras install -y docker

mkdir -p /etc/docker
cat <<EOF | tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
      "max-size": "50m"
  },
  "storage-driver": "overlay2"
}
EOF

service docker start
usermod -a -G docker ec2-user
systemctl enable --now docker
systemctl daemon-reload
systemctl restart docker

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install

cat <<EOF | tee cluster-join.yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
discovery:
  bootstrapToken:
    token: "$JOIN_TOKEN"
    apiServerEndpoint: "${control_plane_endpoint}:$API_PORT"
    caCertHashes:
      - "$CERT_HASH"
nodeRegistration:
  name: "$NODE_NAME"
  kubeletExtraArgs:
    node-labels: "role=control-plane,control-plane-node=join"
controlPlane:
  certificateKey: "$CERT_KEY"
  localAPIEndpoint:
    advertiseAddress: "$IP"
    bindPort: $API_PORT
EOF
