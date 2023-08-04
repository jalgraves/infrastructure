#!/bin/bash

alias k='kubectl' && \
  alias kdelp='kubectl delete pod' && \
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
  alias kgsak='kubectl get serviceaccount -n karpenter'
