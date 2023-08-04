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

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
swapoff -a
yum update -y || sleep 15 && yum update -y
yum install -y bind-utils git iproute-tc jq nmap || sleep 15 && yum install -y bind-utils git iproute-tc jq nmap

# AWS instance metadata endpoint
# http://169.254.169.254/latest/meta-data/

cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

echo "Installing Docker container runtime (CRI)"
sysctl --system
amazon-linux-extras install -y docker

mkdir -p /etc/docker
cat <<EOF | tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=${cgroup_driver}"],
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

# Disable SELinux. Required to allow containers to access the host filesystem,
# which is needed by pod networks for example.
echo "Disabling SELinux"
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

echo "Installing K8s components"
yum install -y \
  kubelet \
  kubeadm \
  kubectl \
  --disableexcludes=kubernetes

systemctl enable --now kubelet
systemctl enable kubelet.service

echo "Installing Helm"
curl --silent https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm repo add cilium https://helm.cilium.io/ && \
  helm repo add jetstack https://charts.jetstack.io &&
  helm repo add aws-ccm https://kubernetes.github.io/cloud-provider-aws && \
  helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver && \
  helm repo add aws https://aws.github.io/eks-charts
  helm repo add external-dns https://kubernetes-sigs.github.io/external-dns
  helm repo add bitnami https://charts.bitnami.com/bitnami && \
  helm repo add hcp https://helm.releases.hashicorp.com  && \
  helm repo add beantown https://beantownpub.github.io/helm/ && \
  helm repo add jetstack https://charts.jetstack.io && \
  helm repo update

# OIDC IRSA
mkdir -p /irsa

echo ${sa_signer_key} | base64 -d > /irsa/sa-signer.key
echo ${sa_signer_pkcs8_pub} | base64 -d > /irsa/sa-signer-pkcs8.pub

echo "Initializing K8s cluster"
mkdir -p /home/ec2-user/manifests
KUBEADM_TOKEN=$(kubeadm token generate)
KUBEADM_CERT_KEY=$(kubeadm certs certificate-key)
IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
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
  bindPort: ${api_port}
nodeRegistration:
  kubeletExtraArgs:
    node-labels: "role=worker,control-plane-node=init"
  criSocket: "unix:/run/containerd/containerd.sock"
  imagePullPolicy: IfNotPresent
  taints: []
  # - effect: NoSchedule
  #   key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
apiServer:
  timeoutForControlPlane: 5m0s
  certSANs:
  - "${control_plane_endpoint}"
  - "$IP"
  extraArgs:
    cloud-provider: external
    service-account-key-file: /irsa/sa-signer-pkcs8.pub
    service-account-signing-key-file: /irsa/sa-signer.key
    api-audiences: sts.amazonaws.com
    service-account-issuer: ${service_account_issuer_url}
  extraVolumes:
    - name: "irsa"
      hostPath: "/irsa"
      mountPath: "/irsa"
      readOnly: false
      pathType: DirectoryOrCreate

certificatesDir: /etc/kubernetes/pki
clusterName: ${cluster_name}
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.k8s.io
kubernetesVersion: ${kubernetes_version}
networking:
  dnsDomain: cluster.local
  serviceSubnet: ${cluster_cidr}
scheduler: {}
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: ${cgroup_driver}
authentication:
  anonymous:
    enabled: ${anonymous_auth_enabled}
authorization:
  mode: ${kubelet_authorization_mode}
serverTLSBootstrap: ${kubelet_tls_bootstrap_enabled}
EOF


kubeadm init \
  --v=10 \
  --config /home/ec2-user/manifests/cluster-config.yaml \
  --upload-certs

export KUBECONFIG=/etc/kubernetes/admin.conf

# Install the cluster's CNI. This cluster uses Cilium
# Hubble displays cluster traffic in a UI
echo "Installing Cilium CNI"
helm upgrade cilium cilium/cilium --install \
  --version ${cilium_version} \
  --namespace kube-system --reuse-values \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set operator.replicas=1 \
  --set debug.enabled=true \
  --set ipam.operator.clusterPoolIPv4PodCIDRList[0]="${cluster_cidr}" \


# Install Cilium's CLI tool for troubleshooting
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/$${CILIUM_CLI_VERSION}/cilium-linux-$${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-$${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-$${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-$${CLI_ARCH}.tar.gz{,.sha256sum}

# Create credentials for ec2-user
mkdir -p "$HOME/.kube"
mkdir /home/ec2-user/.kube
cp -i /etc/kubernetes/admin.conf "$HOME/.kube"/config
cp -i /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
chown 1000:1000 /home/ec2-user/.kube/config

# Create credentials for automated user
kubectl create -n kube-system sa ${automated_user}
kubectl create -n kube-system token ${automated_user}

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${automated_user}-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: ${automated_user}
  namespace: kube-system
EOF

cat <<EOF | tee secret.yaml
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: ${automated_user}
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: "${automated_user}"
EOF

kubectl apply -n kube-system -f secret.yaml
AUTOMATED_USER_TOKEN=$(kubectl --kubeconfig=/etc/kubernetes/admin.conf -n kube-system get secret ${automated_user} -o jsonpath='{.data.token}'| base64 --decode || true)

# Setup automated user auth config
echo "Setting up automated user auth config...."
touch /home/ec2-user/.kube/automated_user
kubectl --kubeconfig=/home/ec2-user/.kube/automated_user config set-credentials ${automated_user} --token="$AUTOMATED_USER_TOKEN"
kubectl --kubeconfig=/home/ec2-user/.kube/automated_user config set-cluster ${cluster_name} --server="https://${control_plane_endpoint}:${api_port}"
kubectl --kubeconfig=/home/ec2-user/.kube/automated_user config set-context ${automated_user} --cluster=${cluster_name} --user=${automated_user}
kubectl --kubeconfig=/home/ec2-user/.kube/automated_user config use-context ${automated_user}
echo "$AUTOMATED_USER_TOKEN" > /home/ec2-user/automated_user_token.txt

function install_ccm() {
  helm upgrade aws-ccm aws-ccm/aws-cloud-controller-manager \
    --install \
    --set args="{\
        --enable-leader-migration=true,\
        --cloud-provider=aws,\
        --v=2,\
        --cluster-cidr=${cluster_cidr},\
        --cluster-name=${cluster_name},\
        --external-cloud-volume-plugin=aws,\
        --configure-cloud-routes=false\
      }"
}

function install_cert_manager() {
  helm upgrade cert-manager jetstack/cert-manager \
    --install \
    --namespace cert-manager \
    --create-namespace \
    --version v1.12.0 \
    --set prometheus.enabled=false
}

function install_pod_identity_webhook() {
  helm upgrade pod-identity-webhook beantown/pod-identity-webhook \
    --install \
    --debug
}

function install_karpenter() {
  echo "Installing Karpenter"
  helm upgrade karpenter oci://public.ecr.aws/karpenter/karpenter \
    --install \
    --debug \
    --create-namespace \
    --version ${karpenter_version} \
    --namespace karpenter \
    --set settings.aws.clusterName=${cluster_name} \
    --set settings.aws.clusterEndpoint="https://$IP:6443" \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${karpenter_service_account_role_arn}" \
    --set replicas=1

  helm upgrade karpenter-provisioners beantown/karpenter-provisioners \
    --install \
    --set clusterName=${cluster_name} \
    --set aws.instanceProfile=${karpenter_instance_profile} \
    --set env=${env}
}

function install_aws_load_balancer_controller() {
  helm upgrade aws-load-balancer-controller aws/aws-load-balancer-controller --install \
    --namespace kube-system \
    --set clusterName=development-use2 \
    --set replicaCount=1
}

function install_aws_external_dns() {
  helm upgrade aws-external-dns external-dns/external-dns --install \
    --namespace kube-system \
    --set logLevel=debug \
    --set logFormat=json
}

function install_istio() {
  helm upgrade istio beantown/istio --install \
    --namespace istio-system \
    --set ingress.albPublic.externalDns.hostnames[0]="*.${cluster_domain}" \
    --set ingress.albPublic.accessLogs.enabled=false \
    --set ingress.albPrivate.enabled=false \
    --set ingress.gatewayDomains[0]="*.${cluster_domain}" \
    --set certArns[0]=${cert_arn} \
    --set sslPolicy=ELBSecurityPolicy-TLS13-1-2-2021-06 \
    --set environment=development \
    --set gateway.replicaCount=1 \
    --set regionCode=use2 \
    --create-namespace \
    --debug
}

function upload_cert() {
  echo "Uploading new apiserver cert to AWS"
  aws iam upload-server-certificate \
    --server-certificate-name ${cluster_name} \
    --certificate-body file://"/etc/kubernetes/pki/apiserver.crt" \
    --private-key file://"/etc/kubernetes/pki/apiserver.key"
}

# function attach_cert() {
#   echo "Attaching cert to NLB listener $${listener_arn}"
#   aws elbv2 modify-listener \
#     --region ${aws_region} \
#     --listener-arn $${listener_arn} \
#     --certificates CertificateArn="arn:aws:iam::${aws_account_id}:server-certificate/${cluster_name}"
# }

if ! install_cert_manager; then
  echo "Exit status $? installing cert manager"
fi
sleep 5

if ! install_pod_identity_webhook; then
  echo "Exit status $? installing pod identity webhook"
fi
sleep 2

if ! install_ccm; then
  echo "Exit status $? installing CCM"
fi
sleep 2

if ! install_karpenter; then
  echo "Exit status $? installing Karpenter"
fi
sleep 2

if ! install_aws_external_dns; then
  echo "Exit status $? installing install_aws_external_dns"
fi
sleep 2
if ! install_aws_load_balancer_controller; then
  echo "Exit status $? installing install_aws_load_balancer_controller"
fi
sleep 2

if ! install_istio; then
  echo "Exit stat $? installing istio"
fi

if [[ ${upload_cert_to_aws_enabled} = "true" ]]; then
  # Upload apiserver certificate to AWS
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  ./aws/install

  echo "Deleting old apiserver cert from AWS"
  aws iam delete-server-certificate --server-certificate-name ${cluster_name} || echo "Error deleting cert"
  sleep 5
  if ! upload_cert; then
    echo "Exit status $? uploading cert. Trying again"
    sleep 15
    upload_cert
  fi

  sleep 15
  # if ! attach_cert; then
  #   echo "Exit status $? attaching cert to listener. Trying again"
  #   sleep 15
  #   attach_cert
  # fi
  # sleep 10
fi

# Create namespaces
kubectl create ns "${env}" && \
  kubectl label namespace "${env}" istio-injection=enabled

echo "Cluster init complete"
