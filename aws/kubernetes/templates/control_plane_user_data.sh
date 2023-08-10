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
    node-labels: "control-plane-node=init"
  criSocket: "unix:/run/containerd/containerd.sock"
  imagePullPolicy: IfNotPresent
  taints: []
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
controlPlaneEndpoint: "${control_plane_endpoint}:${api_port}"
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
curl -s -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/$${CILIUM_CLI_VERSION}/cilium-linux-$${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-$${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-$${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-$${CLI_ARCH}.tar.gz{,.sha256sum}

# Create credentials for ec2-user
mkdir -p "$HOME/.kube"
mkdir /home/ec2-user/.kube
cp -i /etc/kubernetes/admin.conf "$HOME/.kube"/config
cp -i /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
chown 1000:1000 /home/ec2-user/.kube/config

function install_cert_manager() {
  helm upgrade cert-manager jetstack/cert-manager \
    --install \
    --namespace cert-manager \
    --create-namespace \
    --version v1.12.0 \
    --set prometheus.enabled=false \
    --set installCRDs=true
}

CA_CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* /sha256:/')

function install_karpenter() {
  helm upgrade karpenter oci://public.ecr.aws/karpenter/karpenter \
    --install \
    --create-namespace \
    --version ${karpenter_version} \
    --namespace karpenter \
    --set settings.aws.clusterName=${cluster_name} \
    --set settings.aws.clusterEndpoint="https://$IP:${api_port}" \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${karpenter_service_account_role_arn}" \
    --set replicas=${karpenter_replicas}

  sleep 30
  helm upgrade karpenter-provisioners beantown/karpenter-provisioners \
    --install \
    --set clusterName=${cluster_name} \
    --set aws.instanceProfile=${karpenter_instance_profile} \
    --set env=${env} \
    --set consolidation.enabled=false \
    --set aws.availabilityZones="{${availability_zones}}" \
    --set aws.sshPublicKey="${ssh_public_key}" \
    --set apiAddress="$IP" \
    --set apiPort="${api_port}" \
    --set caCertHash="$CA_CERT_HASH" \
    --set joinToken="$KUBEADM_TOKEN" \
    --set controlPlaneEndpoint="${control_plane_endpoint}"
}

function install_pod_identity_webhook() {
  helm upgrade pod-identity-webhook beantown/pod-identity-webhook \
    --install \
    --namespace kube-system
}

function install_aws_load_balancer_controller() {
  helm upgrade aws-load-balancer-controller aws/aws-load-balancer-controller --install \
    --namespace kube-system \
    --set clusterName=${cluster_name} \
    --set replicaCount=1
}

function install_aws_external_dns() {
  helm upgrade aws-external-dns external-dns/external-dns --install \
    --namespace kube-system \
    --set logLevel=debug \
    --set logFormat=json
}

function install_istio() {
  echo "${cert_arns}"
  helm upgrade istio beantown/istio --install \
    --namespace istio-system \
    --set ingress.albPublic.externalDns.hostnames[0]="*.${cluster_domain}" \
    --set ingress.albPublic.accessLogs.enabled=false \
    --set ingress.albPrivate.enabled=false \
    --set ingress.gatewayDomains="{${gateway_domains}}" \
    --set certArns=${cert_arns} \
    --set sslPolicy=ELBSecurityPolicy-TLS13-1-2-2021-06 \
    --set environment=${env} \
    --set gateway.replicaCount=1 \
    --set gateway.nodeSelector.role=worker \
    --set istiod.pilot.nodeSelector.role=worker \
    --set regionCode=${region_code} \
    --set org=${org} \
    --create-namespace
}

function install_argocd() {
  helm upgrade argo-cd beantown/argo-cd --install \
    --namespace argocd \
    --create-namespace
}

if [[ ${ebs_csi_driver_enabled} = "true" ]]; then
  helm upgrade --install aws-ebs-csi-driver \
    --namespace kube-system \
    --set node.tolerateAllTaints=true \
    --set controller.replicaCount=1 \
    aws-ebs-csi-driver/aws-ebs-csi-driver
fi

if [[ ${metrics_server_enabled} = "true" ]]; then
  helm upgrade metrics-server bitnami/metrics-server \
    --namespace kube-system  \
    --set apiService.create=true \
    --install
fi

mkdir -p /var/log/${cluster_name}-crons

cat <<'EOF' > /opt/approve_certs.sh
#!/bin/bash
echo "Running $(date)" >> /var/log/${cluster_name}-crons/approve_certs.txt
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl config use-context kubernetes-admin@${cluster_name}
CSRS=$(kubectl get csr -o custom-columns=NAME:metadata.name --no-headers)
for csr in $CSRS; do
  status=$(kubectl get csr "$csr" -o json | jq .status.condition)
  if [[ "$status" = "null" ]]; then
    echo "Approving $csr" >> /opt/approve_certs_cron_debug.txt
    kubectl certificate approve "$csr"
  fi
done
EOF

chmod +x /opt/approve_certs.sh
echo '*/1 * * * * /bin/bash /opt/approve_certs.sh' >> /var/spool/cron/root

if [[ ${cert_manager_enabled} = "true" ]]; then
  install_cert_manager
fi
sleep 10

if [[ ${pod_identity_webhook_enabled} = "true" ]]; then
  install_pod_identity_webhook
fi
sleep 10

if [[ ${karpenter_enabled} = "true" ]]; then
  install_karpenter
fi
sleep 2

if [[ ${external_dns_enabled} = "true" ]]; then
  install_aws_external_dns
fi
sleep 2

if [[ ${aws_load_balancer_controller_enabled} = "true" ]]; then
  install_aws_load_balancer_controller
fi
sleep 15

if [[ ${istio_enabled} = "true" ]]; then
  install_istio
fi

curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install

# restart stuck gateway pod with image pull error after istio install (no idea why this happens)
ISTIO_GATEWAY_POD=$(kubectl get pods -n istio-system -l app=istio -o jsonpath='{.items[0].metadata.name}')
kubectl delete pods -n istio-system "$ISTIO_GATEWAY_POD"

function upload_cert() {
  cert_name="${cluster_name}-$(date +%h-%d-%Y-%H%M)"
  aws iam upload-server-certificate \
    --region ${aws_region} \
    --server-certificate-name "$cert_name" \
    --certificate-body file://"/etc/kubernetes/pki/apiserver.crt" \
    --private-key file://"/etc/kubernetes/pki/apiserver.key"
}

if ! upload_cert; then
  echo "Exit stat $? upload_cert"
fi

# Create namespaces
kubectl create ns "${env}" && \
  kubectl label namespace "${env}" istio-injection=enabled
