#!/bin/bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034
# shellcheck disable=SC2086
# shellcheck disable=SC2129
# shellcheck disable=SC2193
# shellcheck disable=SC1083
# shellcheck disable=SC2170
# Log output available on instance in /var/log/cloud-init-output.log

sudo su -
printf "\nDisabling swap\n"
swapoff -a
printf "\nRunning yum updates and installs\n"
yum update -y
yum install -y iproute-tc bind-utils jq git

cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
printf "\nInstalling Docker\n"
yum install -y docker

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

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

sudo tee /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes --disableplugin=priorities
systemctl enable --now kubelet

sudo sed -i 's/^#Port 22/Port 3222/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

printf "\nInitializing K8s cluster\n"
mkdir -p /home/ec2-user/manifests
KUBEADM_TOKEN=$(kubeadm token generate)
KUBEADM_CERT_KEY=$(kubeadm certs certificate-key)
echo "$KUBEADM_TOKEN" > /home/ec2-user/kubeadm_token
echo "$KUBEADM_CERT_KEY" > /home/ec2-user/kubeadm_cert_key
IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
AVAILABILITY_ZONE=$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
echo "$IP   ${control_plane_endpoint}" >> /etc/hosts

cat <<EOF | tee /home/ec2-user/manifests/cluster-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
bootstrapTokens:
- token: "$KUBEADM_TOKEN"
  ttl: "0"
certificateKey: "$KUBEADM_CERT_KEY"
localAPIEndpoint:
  advertiseAddress: "$IP"
  bindPort: ${control_plane_port}
nodeRegistration:
  kubeletExtraArgs:
    node-labels: "control-plane-node=init"
  criSocket: "unix:/run/containerd/containerd.sock"
  imagePullPolicy: IfNotPresent
  taints: []
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
apiServer:
  timeoutForControlPlane: 5m0s
  authorization:
    mode: "Node,RBAC"
  certSANs:
  - "${control_plane_endpoint}"
  - "$IP"
  extraArgs:
    cloud-provider: external

controlPlaneEndpoint: "$IP:${control_plane_port}"
certificatesDir: /etc/kubernetes/pki
clusterName: ${cluster_name}
controllerManager:
  extraArgs:
    cluster-signing-cert-file: /etc/kubernetes/pki/ca.crt
    cluster-signing-key-file: /etc/kubernetes/pki/ca.key
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
    extraArgs:
      listen-client-urls: "https://127.0.0.1:2379"
      advertise-client-urls: "https://127.0.0.1:2379"
      listen-peer-urls: "https://127.0.0.1:2380"
imageRepository: registry.k8s.io
kubernetesVersion: ${kubernetes_version}
networking:
  dnsDomain: cluster.local
  serviceSubnet: "${service_subnet}"
scheduler: {}
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
authentication:
  anonymous:
    enabled: false
authorization:
  mode: "Webhook"
serverTLSBootstrap: true
providerID: "aws:///$AVAILABILITY_ZONE/$INSTANCE_ID"
EOF


kubeadm init \
  --v=5 \
  --config /home/ec2-user/manifests/cluster-config.yaml \
  --upload-certs

export KUBECONFIG=/etc/kubernetes/admin.conf

echo "Installing Helm"
curl --silent https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm repo add cilium https://helm.cilium.io/
helm repo add aws https://aws.github.io/eks-charts
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns
helm repo add external-secrets https://charts.external-secrets.io

helm upgrade cilium cilium/cilium --install \
  --version "1.13.0" \
  --namespace kube-system --reuse-values \
  --set hubble.relay.enabled=false \
  --set hubble.ui.enabled=false \
  --set operator.replicas=1 \
  --set debug.enabled=true \
  --set ipam.operator.clusterPoolIPv4PodCIDRList[0]="${service_subnet}"

helm upgrade aws-load-balancer-controller aws/aws-load-balancer-controller \
  --install \
  --namespace kube-system \
  --set clusterName="${cluster_name}" \
  --set replicaCount="1"

helm upgrade aws-external-dns external-dns/external-dns \
  --install \
  --namespace kube-system \
  --set logFormat=json \
  --set policy=sync \
  --set domainFilters[0]="${external_dns_domain}" \
  --set replicaCount="1"

helm upgrade --install external-secrets external-secrets/ \
  --namespace external-secrets \
  --create-namespace \
  --debug

CSRS=$(kubectl get csr -o custom-columns=NAME:metadata.name --no-headers)
for csr in $CSRS; do
  status=$(kubectl get csr "$csr" -o json | jq .status.condition)
  if [[ "$status" = "null" ]]; then
    echo "Approving $csr" >> /opt/approve_certs_cron_debug.txt
    kubectl certificate approve "$csr"
  fi
done

kubectl create namespace ${environment}
kubectl label namespace ${environment} istio-injection=enabled

NODE=$(kubectl get nodes -o custom-columns=NAME:metadata.name --no-headers)
kubectl label node "$NODE" role=istio
