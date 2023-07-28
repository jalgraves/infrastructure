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
  helm repo add bitnami https://charts.bitnami.com/bitnami && \
  helm repo add hcp https://helm.releases.hashicorp.com  && \
  helm repo update


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
    node-labels: "role=control-plane,control-plane-node=init"
  criSocket: "unix:/run/containerd/containerd.sock"
  imagePullPolicy: IfNotPresent
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
apiServer:
  timeoutForControlPlane: 7m0s
  certSANs:
  - "${control_plane_endpoint}"
  - "${nlb_hostname}"
  - "$IP"
  extraArgs:
    cloud-provider: external
certificatesDir: /etc/kubernetes/pki
clusterName: ${cluster_name}
controlPlaneEndpoint: ${control_plane_endpoint}:${api_port}
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
  --v=6 \
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
  --set ipam.operator.clusterPoolIPv4PodCIDRList[0]="${cluster_cidr}"

# Install Cilium's CLI tool for troubleshooting
curl \
  --silent \
  -L \
  --remote-name-all \
  https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
rm cilium-linux-amd64.tar.gz

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
kind: ClusterRole
metadata:
  name: node-api-access
rules:
- nonResourceURLs:
  - /api
  - /api/v1
  - /apis
  - /apis/*
  - /swagger-2.0.0.pb-v1
  - /openapi
  - /openapi/v2
  verbs:
  - get
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-api-access
subjects:
- kind: User
  name: "system:anonymous"
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: node-api-access
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: terraform-kube-system
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: terraform-kube-system
subjects:
- kind: User
  name: "system:anonymous"
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: "system:unauthenticated"
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: terraform-kube-system
  apiGroup: rbac.authorization.k8s.io
EOF

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

# Kubelet CSR signer
#kubectl apply -f https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml

# Setup automated user auth config
echo "Setting up automated user auth config...."
touch /home/ec2-user/.kube/automated_user
kubectl --kubeconfig=/home/ec2-user/.kube/automated_user config set-credentials ${automated_user} --token="$AUTOMATED_USER_TOKEN"
kubectl --kubeconfig=/home/ec2-user/.kube/automated_user config set-cluster ${cluster_name} --server="https://k8s.${region_code}.${domain_name}:${api_port}"
kubectl --kubeconfig=/home/ec2-user/.kube/automated_user config set-context ${automated_user} --cluster=${cluster_name} --user=${automated_user}
kubectl --kubeconfig=/home/ec2-user/.kube/automated_user config use-context ${automated_user}
echo "$AUTOMATED_USER_TOKEN" > /home/ec2-user/automated_user_token.txt

function upload_cert() {
  echo "Uploading new apiserver cert to AWS"
  aws iam upload-server-certificate \
    --server-certificate-name ${cluster_name} \
    --certificate-body file://"/etc/kubernetes/pki/apiserver.crt" \
    --private-key file://"/etc/kubernetes/pki/apiserver.key"
}

function attach_cert() {
  echo "Attaching cert to NLB listener ${listener_arn}"
  aws elbv2 modify-listener \
    --region ${aws_region} \
    --listener-arn ${listener_arn} \
    --certificates CertificateArn="arn:aws:iam::${aws_account_id}:server-certificate/${cluster_name}"
}

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
  if ! attach_cert; then
    echo "Exit status $? attaching cert to listener. Trying again"
    sleep 15
    attach_cert
  fi
  sleep 10
fi

# Create namespaces
kubectl create ns "${env}" && \
  kubectl label namespace "${env}" istio-injection=enabled



kubectl config use-context kubernetes-admin@${cluster_name}

cat <<'EOF' > /opt/delete_nodes.sh
#!/bin/bash
printf "\n\n$(date +%Y-%m-%dT%H:%M:%S) - Running delete_nodes.sh" >> /var/log/${cluster_name}-crons/delete_nodes.txt

export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl config use-context kubernetes-admin@${cluster_name}

function check_kubelet_status() {
  kubectl get node "$1" -o json | jq '.status.conditions[].message' | grep "Kubelet stopped posting"
}

function fetch_etcd_member_id() {
  ETCD_MEMBER_ID=$(\
  kubectl exec "$1" \
    -n kube-system \
    -- \
    etcdctl \
      --cacert /etc/kubernetes/pki/etcd/ca.crt \
      --cert /etc/kubernetes/pki/etcd/peer.crt \
      --key /etc/kubernetes/pki/etcd/peer.key \
      member list | grep "$2" | cut -f 1 -d,)
}

function remove_etcd_members() {
  kubectl exec "$1" \
    -n kube-system \
    -- \
    etcdctl \
      --cacert /etc/kubernetes/pki/etcd/ca.crt \
      --cert /etc/kubernetes/pki/etcd/peer.crt \
      --key /etc/kubernetes/pki/etcd/peer.key \
      member remove "$2"
}

HEALTHY_NODE=$(kubectl get nodes -l role=control-plane --no-headers | grep -v 'NotReady' | awk '{print $1}' | head -n 1)
printf "\n$(date +%Y-%m-%dT%H:%M:%S) - Healthy Node: $HEALTHY_NODE" >> /var/log/${cluster_name}-crons/delete_nodes.txt

NODES=$(kubectl get nodes -o custom-columns=NAME:metadata.name --no-headers)
for node in $NODES; do
  status=$(kubectl get node "$node" -o json | jq '.metadata.labels["status"]')
  if [[ "$status" != "null" ]]; then
    printf "\n$(date +%Y-%m-%dT%H:%M:%S) - $node is locked, exiting" >> /var/log/${cluster_name}-crons/delete_nodes.txt
    continue
  else
    printf "\n$(date +%Y-%m-%dT%H:%M:%S) - Locking $node" >> /var/log/${cluster_name}-crons/delete_nodes.txt
    kubectl label node "$node" status=locked
  fi
  failures=0
  max_failures=5
  while (("$failures" < "$max_failures")); do
    if check_kubelet_status "$node"; then
      failures=$((failures + 1))
      printf "\n$(date +%Y-%m-%dT%H:%M:%S) - Node $node failures: $failures" >> /var/log/${cluster_name}-crons/delete_nodes.txt
      sleep 60
    else
      printf "\n$(date +%Y-%m-%dT%H:%M:%S) - Unlocking $node | Stable after $failures failures" >> /var/log/${cluster_name}-crons/delete_nodes.txt
      kubectl label node "$node" status-
      break
    fi
    if [[ $failures -eq $max_failures ]]; then
      fetch_etcd_member_id "etcd-$HEALTHY_NODE" "$node"
      if [[ -n "$ETCD_MEMBER_ID" ]]; then
        printf "\n$(date +%Y-%m-%dT%H:%M:%S) - Removing ETCD member: $ETCD_MEMBER_ID" >> /var/log/${cluster_name}-crons/delete_nodes.txt
        remove_etcd_members "etcd-$HEALTHY_NODE" "$ETCD_MEMBER_ID"
      fi
      printf "\n$(date +%Y-%m-%dT%H:%M:%S) - Draining $node" >> /var/log/${cluster_name}-crons/delete_nodes.txt
      kubectl drain "$node" --ignore-daemonsets --delete-emptydir-data --force=true --skip-wait-for-delete-timeout=30 --timeout=600s
      printf "\n$(date +%Y-%m-%dT%H:%M:%S) - Deleting $node" >> /var/log/${cluster_name}-crons/delete_nodes.txt
      kubectl delete node "$node"
    fi
  done
done
printf "\n"
EOF

chmod +x /opt/delete_nodes.sh
echo '*/5 * * * * /bin/bash /opt/delete_nodes.sh' >> /var/spool/cron/root

echo "Cluster init complete"
