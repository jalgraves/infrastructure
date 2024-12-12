#!/bin/bash

export KUBECONFIG=/etc/kubernetes/admin.conf && export PATH=$PATH:/usr/local/bin && \
alias k='kubectl' && \
  alias kdel='kubectl delete' && \
  alias kdelp='kubectl delete pod' && \
  alias kd='kubectl describe' && \
  alias kg='kubectl get' && \
  alias kgp='kubectl get pods' && \
  alias kgpa='kubectl get pods -A' && \
  alias kgn='kubectl get nodes' && \
  alias kgs='kubectl get secrets' && \
  alias kgsa='kubectl get secrets -A' && \
  alias kdp='kubectl describe pods' && \
  alias kl='kubectl logs' && \
  alias klks='kubectl logs -n kube-system' && \
  alias kdelpks='kubectl delete pod -n kube-system' && \
  alias kdpks='kubectl describe pod -n kube-system' && \
  alias kgpks='kubectl get pods -n kube-system' && \
  alias kgsks='kubectl get secrets -n kube-system' && \
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
  alias kgsargo='kubectl get secrets -n argocd' && \
  alias klargo='kubectl logs -n argocd' && \
  alias kdelpargo='kubectl delete pod -n argocd' && \
  alias kdpargo='kubectl describe pod -n argocd' && \
  alias kgpargo='kubectl get pods -n argocd' && \
  alias b='base64' && \
  alias bd='base64 -d' && \
  alias kgpex='kubectl get pods -n external-secrets' && \
  alias kdelpex='kubectl delete pods -n external-secrets' && \
  alias kdpex='kubectl describe pods -n external-secrets' && \
  alias klex='kubectl logs -n external-secrets' && \
  alias kdelpp='kubectl delete pod -n production' && \
  alias kdpp='kubectl describe pod -n production' && \
  alias kgpp='kubectl get pod -n production' && \
  alias kgsecp='kubectl get secrets -n production' && \
  alias klp='kubectl logs -n production' && \
  alias kdelsecp='kubectl delete secrets -n production' && \
  alias hup='helm uninstall -n production'
