#!/bin/bash

ARGS=("$@")
ARG_INDEX=0
for arg in "${ARGS[@]}"; do
  value=$((ARG_INDEX+1))
  case $arg in
    --asg_name)
      ASG_NAME="${ARGS[$value]}"
      ;;
    --argocd_enabled)
      ARGOCD_ENABLED="${ARGS[$value]}"
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
    --cert_arns)
      CERT_ARNS="${ARGS[$value]}"
      ;;
    --cluster_autoscaler_enabled)
      CLUSTER_AUTOSCALER_ENABLED="${ARGS[$value]}"
      ;;
    --cluster_domain)
      CLUSTER_DOMAIN="${ARGS[$value]}"
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
    --cert_manager_enabled)
      CERT_MANAGER_ENABLED="${ARGS[$value]}"
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

if [[ ${CLUSTER_AUTOSCALER_ENABLED} = "true" ]]; then
  helm repo add autoscaler https://kubernetes.github.io/autoscaler
  helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler \
    --namespace kube-system \
    --set nameOveride=cluster-autoscaler \
    --set extraArgs.scale-down-unneeded-time=5m \
    --set extraArgs.scale-down-unready-time=5m \
    --set "autoscalingGroups[0].name=$ASG_NAME" \
    --set "awsRegion=$REGION" \
    --set "autoscalingGroups[0].maxSize=2" \
    --set "autoscalingGroups[0].minSize=1" \
    --set awsAccessKeyID="$AWS_ACCESS_KEY_ID" \
    --set awsSecretAccessKey="$AWS_SECRET_ACCESS_KEY"
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

if [[ ${ARGOCD_ENABLED} = "true" ]]; then
  kubectl create namespace argocd
  echo "${GITHUB_SSH_SECRET}" | base64 -d > /home/ec2-user/.ssh/argo_ed25519
  kubectl create secret generic github-ssh -n argocd --from-file=sshPrivateKey=/home/ec2-user/.ssh/argo_ed25519
  helm upgrade argo-cd beantown/argo-cd \
    --install \
    --namespace argocd \
    --create-namespace
fi
