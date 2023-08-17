#!/bin/bash

export KUBECONFIG=/etc/kubernetes/admin.conf && export PATH=$PATH:/usr/local/bin && \
alias k='kubectl' && \
  alias kdelp='kubectl delete pod' && \
  alias kd='kubectl describe' && \
  alias kg='kubectl get' && \
  alias kgp='kubectl get pods' && \
  alias kgpa='kubectl get pods -A' && \
  alias kgn='kubectl get nodes' && \
  alias kdp='kubectl describe pods' && \
  alias kl='kubectl logs' && \
  alias klks='kubectl logs -n kube-system' && \
  alias kdelpks='kubectl delete pod -n kube-system' && \
  alias kdpks='kubectl describe pod -n kube-system' && \
  alias kgpks='kubectl get pods -n kube-system' && \
  alias h='helm' && \
  alias hl='helm list' && \
  alias c='cilium' && \
  alias kgpk='kubectl get pods -n karpenter' && \
  alias kdelpk='kubectl delete pod -n karpenter' && \
  alias klk='kubectl logs -n karpenter' && \
  alias hru='helm repo update' && \
  alias hu='helm uninstall' && \
  alias hsr='helm search repo' && \
  alias cri='crictl --runtime-endpoint unix:/run/containerd/containerd.sock' && \
  alias sctl='systemctl' && \
  alias sctls='systemctl status' && \
  alias kgpro='kubectl get provisioners' && \
  alias kgsak='kubectl get serviceaccount -n karpenter' && \
  alias kca='kubectl certificate approve' && \
  alias kgpi='kubectl get pod -n istio-system' && \
  alias kgii='kubectl get ingress -n istio-system' && \
  alias kdelpi='kubectl delete pod -n istio-system' && \
  alias kdi='kubectl describe ingress -n istio-system' && \
  alias kggwi='kubectl get gateway -n istio-system' && \
  alias kdgwi='kubectl describe gateway -n istio-system' && \
  alias kegwi='kubectl edit gateway -n istio-system' && \
  alias kdpi='kubectl describe pod -n istio-system' && \
  alias klargo='kubectl logs -n argocd' && \
  alias kdelpargo='kubectl delete pod -n argocd' && \
  alias kdpargo='kubectl describe pod -n argocd' && \
  alias kgpargo='kubectl get pods -n argocd'

helm repo add beantown https://beantownpub.github.io/helm/

function install_istio() {
  helm upgrade istio beantown/istio --install \
    --namespace istio-system \
    --set argoCd.enabled=true \
    --set ingress.albPublic.externalDns.hostnames[0]="*.use2.production.aws.beantownpub.com" \
    --set ingress.albPublic.accessLogs.enabled=false \
    --set ingress.albPrivate.enabled=false \
    --set ingress.gatewayDomains="{*.beantownpub.com}" \
    --set certArns="{arn:aws:acm:us-east-2:112138771825:certificate/43391e28-c1f0-433e-b7f6-2f5b396d57ff,arn:aws:acm:us-east-2:112138771825:certificate/2993acd8-dd01-495b-b63f-41a963e341b2,arn:aws:acm:us-east-2:112138771825:certificate/1f40cdb6-13b9-4d7d-a949-75ff72886768,arn:aws:acm:us-east-2:112138771825:certificate/768b1eba-32c1-42ff-91e4-cc6e864091d8,arn:aws:acm:us-east-2:112138771825:certificate/0ce52cbf-0f61-4e97-92ac-fa0460b67081}" \
    --set sslPolicy=ELBSecurityPolicy-TLS13-1-2-2021-06 \
    --set environment=production \
    --set gateway.replicaCount=1 \
    --set gateway.nodeSelector.role=worker \
    --set istiod.pilot.nodeSelector.role=worker \
    --set regionCode=use2 \
    --set org=beantownpub \
    --create-namespace
}

helm upgrade aws-external-dns external-dns/external-dns --install \
    --namespace kube-system \
    --set logLevel=debug \
    --set logFormat=json \
    --set policy=sync \
    --set domainFilters[0]="use2.production.aws.beantownpub.com" \
    --set replicaCount=1

helm repo add aws https://aws.github.io/eks-charts
helm upgrade aws-load-balancer-controller aws/aws-load-balancer-controller --install \
  --namespace kube-system \
  --version 1.5.2 \
  --set clusterName=production-use2 \
  --set replicaCount=1 \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::112138771825:role/ProductionUse2K8sKarpenter" \
  --debug

helm repo add aws-ccm https://kubernetes.github.io/cloud-provider-aws
helm upgrade aws-ccm aws-ccm/aws-cloud-controller-manager \
    --install \
    --set args="{\
        --enable-leader-migration=true,\
        --cloud-provider=aws,\
        --v=2,\
        --cluster-cidr=10.96.0.0/12,\
        --cluster-name=production-use2,\
        --external-cloud-volume-plugin=aws,\
        --configure-cloud-routes=false\
    }"

helm upgrade karpenter oci://public.ecr.aws/karpenter/karpenter \
    --install \
    --create-namespace \
    --version "v0.29.2" \
    --namespace karpenter \
    --set settings.aws.clusterName="production-use2" \
    --set settings.aws.clusterEndpoint="https://10.6.35.183:6443" \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::112138771825:role/ProductionUse2K8sKarpenter" \
    --set replicas="1"
