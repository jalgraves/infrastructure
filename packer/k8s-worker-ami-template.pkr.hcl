

data "amazon-ami" "this" {
  filters = {
    virtualization-type = "hvm"
    name                = "amzn2-ami-kernel-5.10-hvm-2.0.*-x86_64-gp2"
    name                = "amzn2-ami-hvm-2.0.*-x86_64-gp2"
    root-device-type    = "ebs"
  }
  owners      = ["amazon"]
  most_recent = true
  region      = "us-east-2"
}

source "amazon-ebs" "k8s-worker" {
  ami_name             = "production_use2_k8s_worker {{timestamp}}"
  instance_type        = "t2.micro"
  region               = "us-east-2"
  source_ami           = data.amazon-ami.this.id
  ssh_username         = "ec2-user"
  ssh_interface        = "public_ip"
  communicator         = "ssh"
  iam_instance_profile = "ProductionUse2Packer"
  subnet_filter {
    filters = {
      "tag:cpco.io/subnet/type": "public"
    }
    most_free = true
    random = false
  }
  temporary_security_group_source_public_ip = true
  tags = {
    "cpco.io/ami/type" = "k8s-worker"
    "cpco.io/ami/env" = "production"
  }
  // user_data_file = "../aws/kubernetes/templates/join_cluster.sh"
}

build {
  sources = ["source.amazon-ebs.k8s-worker"]

  provisioner "shell" {
    inline = [
      "sudo swapoff -a",
      "sudo yum update -y",
      "sudo yum install -y iproute-tc bind-utils jq nmap git",
      "sudo echo 'br_netfilter' | sudo tee /etc/modules-load.d/k8s.conf",
    ]
  }
  provisioner "shell" {
    inline = [
      <<EOF

sudo cat <<EOC | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOC

sudo sysctl --system
echo "Installing docker"
sudo amazon-linux-extras install -y docker
echo "Updating docker config"
sudo mkdir -p /etc/docker
sudo cat <<EOC | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
      "max-size": "50m"
  },
  "storage-driver": "overlay2"
}
EOC
EOF
,<<EOF
echo "Starting docker"
sudo service docker start
echo "Modifying users"
sudo usermod -a -G docker ec2-user
echo "Updating systemctl"
sudo systemctl enable --now docker
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "Updating SELinux config"
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config || echo "WTF SELINUX"

echo "Adding kubernetes repo"
sudo cat <<EOC | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOC

echo "Installing kubeadm"
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
echo "Updating systemctl kubelet"
sudo systemctl enable --now kubelet || true

echo "Installing awscli"
sudo curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip -q awscliv2.zip
sudo ./aws/install
      EOF
    ]
  }
}
