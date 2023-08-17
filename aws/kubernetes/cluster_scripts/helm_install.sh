#!/bin/bash

ARGS=("$@")
ARG_INDEX=0
for arg in "${ARGS[@]}"; do
  value=$((ARG_INDEX+1))
  case $arg in
    --api_port)
      API_PORT="${ARGS[$value]}"
      ;;
    --asg-name)
      ASG_NAME="${ARGS[$value]}"
      ;;
    --aws_load_balancer_controller_enabled)
      AWS_LOAD_BALANCER_CONTROLLER_ENABLED="${ARGS[$value]}"
      ;;
    --aws_load_balancer_controller_replicas)
      AWS_LOAD_BALANCER_CONTROLLER_REPLICAS="${ARGS[$value]}"
      ;;
    --aws_external_dns_enabled)
      AWS_EXTERNAL_DNS_ENABLED="${ARGS[$value]}"
      ;;
    --aws_external_dns_replicas)
      AWS_EXTERNAL_DNS_REPLICAS="${ARGS[$value]}"
      ;;
    --aws_access_key_id)
      AWS_ACCESS_KEY_ID="${ARGS[$value]}"
      ;;
    --aws_secret_access_key)
      AWS_SECRET_ACCESS_KEY="${ARGS[$value]}"
      ;;
    --availability_zones)
      AVAILABILITY_ZONES="${ARGS[$value]}"
      ;;
    --cert_arns)
      CERT_ARNS="${ARGS[$value]}"
      ;;
    --cluster_auto_scaler_enabled)
      CLUSTER_AUTOSCALER_ENABLED="${ARGS[$value]}"
      ;;
    --cluster_domain)
      CLUSTER_DOMAIN="${ARGS[$value]}"
      ;;
    --control_plane_endpoint)
      CONTROL_PLANE_ENDPOINT="${ARGS[$value]}"
      ;;
    --ebs_csi_driver_enabled)
      EBS_CSI_DRIVER_ENABLED="${ARGS[$value]}"
      ;;
    --cilium_version)
      CILIUM_VERSION="${ARGS[$value]}"
      ;;
    --cluster_name)
      CLUSTER_NAME="${ARGS[$value]}"
      ;;
    --cluster_cidr)
      CLUSTER_CIDR="${ARGS[$value]}"
      ;;
    --env)
      ENV="${ARGS[$value]}"
      ;;
    --github_ssh_secret)
      GITHUB_SSH_SECRET="${ARGS[$value]}"
      ;;
    --gateway_domains)
      GATEWAY_DOMAINS="${ARGS[$value]}"
      ;;
    --metrics_server_enabled)
      METRICS_SERVER_ENABLED="${ARGS[$value]}"
      ;;
    --org)
      ORG="${ARGS[$value]}"
      ;;
    --pod_identity_webhook_enabled)
      POD_IDENTITY_WEBHOOK_ENABLED="${ARGS[$value]}"
      ;;
    --region_code)
      REGION_CODE="${ARGS[$value]}"
      ;;
    --region)
      REGION="${ARGS[$value]}"
      ;;
    # --ssh_public_key)
    #   SSH_PUBLIC_KEY="${ARGS[$value]}"
    #   ;;
    --cert_manager_enabled)
      CERT_MANAGER_ENABLED="${ARGS[$value]}"
      ;;
    --karpenter_instance_profile)
      KARPENTER_INSTANCE_PROFILE="${ARGS[$value]}"
      ;;
    --karpenter_enabled)
      KARPENTER_ENABLED="${ARGS[$value]}"
      ;;
    --karpenter_version)
      KARPENTER_VERSION="${ARGS[$value]}"
      ;;
    --karpenter_service_account_role_arn)
      KARPENTER_SERVICE_ACCOUNT_ROLE_ARN="${ARGS[$value]}"
      ;;
    --karpenter_replicas)
      KARPENTER_REPLICAS="${ARGS[$value]}"
      ;;
  esac
  ((ARG_INDEX=ARG_INDEX+1))
done

echo "Installing Helm"
curl --silent https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm repo add cilium https://helm.cilium.io/ && \
  helm repo add aws-ccm https://kubernetes.github.io/cloud-provider-aws && \
  helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver && \
  helm repo add aws https://aws.github.io/eks-charts
  helm repo add external-dns https://kubernetes-sigs.github.io/external-dns
  helm repo add bitnami https://charts.bitnami.com/bitnami && \
  helm repo add hcp https://helm.releases.hashicorp.com  && \
  helm repo add beantown https://beantownpub.github.io/helm/ && \
  helm repo add jetstack https://charts.jetstack.io && \
  helm repo update

export KUBECONFIG=/etc/kubernetes/admin.conf

# Install the cluster's CNI. This cluster uses Cilium
# Hubble displays cluster traffic in a UI
echo "Installing Cilium CNI"
helm upgrade cilium cilium/cilium --install \
  --version "${CILIUM_VERSION}" \
  --namespace kube-system --reuse-values \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set operator.replicas=1 \
  --set debug.enabled=true \
  --set ipam.operator.clusterPoolIPv4PodCIDRList[0]="${CLUSTER_CIDR}"

sleep 10

# IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
# KUBEADM_TOKEN=$(cat /home/ec2-user/kubeadm_token)
# CA_CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* /sha256:/')

# function install_karpenter() {
#   helm upgrade karpenter oci://public.ecr.aws/karpenter/karpenter \
#     --install \
#     --create-namespace \
#     --version "${KARPENTER_VERSION}" \
#     --namespace karpenter \
#     --set settings.aws.clusterName="${CLUSTER_NAME}" \
#     --set settings.aws.clusterEndpoint="https://$IP:${API_PORT}" \
#     --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${KARPENTER_SERVICE_ACCOUNT_ROLE_ARN}" \
#     --set replicas="${KARPENTER_REPLICAS}"

#   sleep 30
#   helm upgrade karpenter-provisioners beantown/karpenter-provisioners \
#     --install \
#     --set clusterName="${CLUSTER_NAME}" \
#     --set aws.instanceProfile="${KARPENTER_INSTANCE_PROFILE}" \
#     --set env="${ENV}" \
#     --set consolidation.enabled=false \
#     --set aws.availabilityZones="{${AVAILABILITY_ZONES}}" \
#     --set aws.sshPublicKey="${SSH_PUBLIC_KEY}" \
#     --set apiAddress="$IP" \
#     --set apiPort="${API_PORT}" \
#     --set caCertHash="$CA_CERT_HASH" \
#     --set joinToken="$KUBEADM_TOKEN" \
#     --set controlPlaneEndpoint="${CONTROL_PLANE_ENDPOINT}"
# }

function install_ca() {
  helm repo add autoscaler https://kubernetes.github.io/autoscaler
  helm upgrade --install my-release autoscaler/cluster-autoscaler \
    --set "autoscalingGroups[0].name=$ASG_NAME" \
    --set "awsRegion=$REGION" \
    --set "autoscalingGroups[0].maxSize=2" \
    --set "autoscalingGroups[0].minSize=1" \
    --set awsAccessKeyID="$AWS_ACCESS_KEY_ID" \
    --set awsSecretAccessKey="$AWS_SECRET_ACCESS_KEY"
}


function install_argocd() {
  kubectl create namespace argocd
  helm upgrade istio beantown/istio \
    --install \
    --namespace istio-system \
    --set argoCd.enabled=true \
    --set ingress.albPublic.externalDns.hostnames[0]="*.${CLUSTER_DOMAIN}" \
    --set ingress.albPublic.accessLogs.enabled=false \
    --set ingress.albPrivate.enabled=false \
    --set ingress.gatewayDomains="{${GATEWAY_DOMAINS}}" \
    --set certArns="{${CERT_ARNS}}" \
    --set sslPolicy=ELBSecurityPolicy-TLS13-1-2-2021-06 \
    --set environment="${ENV}" \
    --set gateway.replicaCount=1 \
    --set gateway.nodeSelector.role=worker \
    --set istiod.pilot.nodeSelector.role=worker \
    --set regionCode="${REGION_CODE}" \
    --set org="${ORG}" \
    --create-namespace
  sleep 10
  echo "${GITHUB_SSH_SECRET}" | base64 -d > /home/ec2-user/.ssh/argo_ed25519
  kubectl create secret generic github-ssh -n argocd --from-file=sshPrivateKey=/home/ec2-user/.ssh/argo_ed25519

  helm upgrade argo-cd beantown/argo-cd \
    --install \
    --namespace argocd \
    --create-namespace
}

if [[ ${METRICS_SERVER_ENABLED} = "true" ]]; then
  helm upgrade metrics-server bitnami/metrics-server \
    --namespace kube-system  \
    --set apiService.create=true \
    --install
  sleep 5
fi

if [[ ${EBS_CSI_DRIVER_ENABLED} = "true" ]]; then
  helm upgrade --install aws-ebs-csi-driver \
    --namespace kube-system \
    --set node.tolerateAllTaints=true \
    --set controller.replicaCount=1 \
    aws-ebs-csi-driver/aws-ebs-csi-driver
fi

if [[ ${CERT_MANAGER_ENABLED} = "true" ]]; then
  helm upgrade cert-manager jetstack/cert-manager \
    --install \
    --namespace cert-manager \
    --create-namespace \
    --version v1.12.0 \
    --set prometheus.enabled=false \
    --set installCRDs=true
fi
sleep 10

if [[ ${POD_IDENTITY_WEBHOOK_ENABLED} = "true" ]]; then
  helm upgrade pod-identity-webhook beantown/pod-identity-webhook \
    --install \
    --namespace kube-system
fi
sleep 10

# if [[ ${KARPENTER_ENABLED} = "true" ]]; then
#   install_karpenter
# fi
# sleep 2

if [[ ${CLUSTER_AUTOSCALER_ENABLED} = "true" ]]; then
  install_ca
fi
sleep 2

if [[ ${AWS_EXTERNAL_DNS_ENABLED} = "true" ]]; then
  helm upgrade aws-external-dns external-dns/external-dns \
    --install \
    --namespace kube-system \
    --set logFormat=json \
    --set policy=sync \
    --set domainFilters[0]="${CLUSTER_DOMAIN}" \
    --set replicaCount="${AWS_EXTERNAL_DNS_REPLICAS}"
fi


if [[ ${AWS_LOAD_BALANCER_CONTROLLER_ENABLED} = "true" ]]; then
  helm upgrade aws-load-balancer-controller aws/aws-load-balancer-controller \
    --install \
    --namespace kube-system \
    --set clusterName="${CLUSTER_NAME}" \
    --set replicaCount="${AWS_LOAD_BALANCER_CONTROLLER_REPLICAS}"
  sleep 15
fi

install_argocd
