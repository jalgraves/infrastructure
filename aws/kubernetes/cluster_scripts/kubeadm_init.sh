#!/bin/bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034
# shellcheck disable=SC2086
# shellcheck disable=SC2129
# shellcheck disable=SC2193
# shellcheck disable=SC1083
# shellcheck disable=SC2170
# Log output available on instance in /var/log/cloud-init-output.log
ARGS=("$@")
ARG_INDEX=0
for arg in "${ARGS[@]}"; do
  value=$((ARG_INDEX+1))
  case $arg in
    --api_port)
      API_PORT="${ARGS[$value]}"
      ;;
    --anonymous_auth_enabled)
      ANONYMOUS_AUTH_ENABLED="${ARGS[$value]}"
      ;;
    --cgroup_driver)
      CGROUP_DRIVER="${ARGS[$value]}"
      ;;
    --cluster_name)
      CLUSTER_NAME="${ARGS[$value]}"
      ;;
    --cluster_cidr)
      CLUSTER_CIDR="${ARGS[$value]}"
      ;;
    --kubelet_tls_bootstrap_enabled)
      KUBELET_TLS_BOOTSTRAP_ENABLED="${ARGS[$value]}"
      ;;
    --kubelet_authorization_mode)
      KUBELET_AUTHORIZATION_MODE="${ARGS[$value]}"
      ;;
    --kubernetes_version)
      KUBERNETES_VERSION="${ARGS[$value]}"
      ;;
    --sa_signer_pkcs8_pub)
      SA_SIGNER_PKCS8_PUB="${ARGS[$value]}"
      ;;
    --sa_signer_key)
      SA_SIGNER_KEY="${ARGS[$value]}"
      ;;
    --control_plane_endpoint)
      CONTROL_PLANE_ENDPOINT="${ARGS[$value]}"
      ;;
    --service_account_issuer_url)
      SERVICE_ACCOUNT_ISSUER_URL="${ARGS[$value]}"
      ;;
  esac
  ((ARG_INDEX=ARG_INDEX+1))
done

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
  "exec-opts": ["native.cgroupdriver=${CGROUP_DRIVER}"],
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

# OIDC IRSA
mkdir -p /irsa

echo "${SA_SIGNER_KEY}" | base64 -d > /irsa/sa-signer.key
echo "${SA_SIGNER_PKCS8_PUB}" | base64 -d > /irsa/sa-signer-pkcs8.pub

echo "Initializing K8s cluster"
mkdir -p /home/ec2-user/manifests
KUBEADM_TOKEN=$(kubeadm token generate)
KUBEADM_CERT_KEY=$(kubeadm certs certificate-key)
echo "${KUBEADM_TOKEN}" > /home/ec2-user/kubeadm_token
echo "${KUBEADM_CERT_KEY}" > /home/ec2-user/kubeadm_cert_key
IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
echo "$IP   ${CONTROL_PLANE_ENDPOINT}" >> /etc/hosts

cat <<EOF | tee /home/ec2-user/manifests/cluster-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
bootstrapTokens:
- token: "$KUBEADM_TOKEN"
  ttl: "0"
certificateKey: "$KUBEADM_CERT_KEY"
localAPIEndpoint:
  advertiseAddress: "$IP"
  bindPort: ${API_PORT}
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
  - "${CONTROL_PLANE_ENDPOINT}"
  - "$IP"
  extraArgs:
    cloud-provider: aws
    service-account-key-file: /irsa/sa-signer-pkcs8.pub
    service-account-signing-key-file: /irsa/sa-signer.key
    api-audiences: sts.amazonaws.com
    service-account-issuer: ${SERVICE_ACCOUNT_ISSUER_URL}
  extraVolumes:
    - name: "irsa"
      hostPath: "/irsa"
      mountPath: "/irsa"
      readOnly: false
      pathType: DirectoryOrCreate
controlPlaneEndpoint: "${CONTROL_PLANE_ENDPOINT}:${API_PORT}"
certificatesDir: /etc/kubernetes/pki
clusterName: ${CLUSTER_NAME}
controllerManager:
  extraArgs:
    cluster-signing-cert-file: /etc/kubernetes/pki/ca.crt
    cluster-signing-key-file: /etc/kubernetes/pki/ca.key
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.k8s.io
kubernetesVersion: ${KUBERNETES_VERSION}
networking:
  dnsDomain: cluster.local
  serviceSubnet: ${CLUSTER_CIDR}
scheduler: {}
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: ${CGROUP_DRIVER}
authentication:
  anonymous:
    enabled: ${ANONYMOUS_AUTH_ENABLED}
authorization:
  mode: ${KUBELET_AUTHORIZATION_MODE}
serverTLSBootstrap: ${KUBELET_TLS_BOOTSTRAP_ENABLED}
EOF


kubeadm init \
  --v=10 \
  --config /home/ec2-user/manifests/cluster-config.yaml \
  --upload-certs

# Create credentials for ec2-user
mkdir -p "$HOME/.kube"
mkdir /home/ec2-user/.kube
cp -i /etc/kubernetes/admin.conf "$HOME/.kube"/config
cp -i /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
chown 1000:1000 /home/ec2-user/.kube/config

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
