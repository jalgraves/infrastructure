#!/bin/bash

# disable shellcheck for terraform template vars
# shellcheck disable=SC2154
# shellcheck disable=SC2086
# shellcheck disable=SC2034
# shellcheck disable=SC2193
# shellcheck disable=SC2182
# shellcheck disable=SC2059
# Log output available on instance in /var/log/cloud-init-output.log
CLUSTER_SECRET=$(aws secretsmanager get-secret-value --region ${region} \
  --secret-id ${cluster_name}-cluster-secret | jq -r '.SecretString' | jq '.' | jq
)
JOIN_TOKEN=$(echo "$CLUSTER_SECRET" | jq -r '.join_token')
CA_CERT_HASH=$(echo "$CLUSTER_SECRET" | jq -r '.ca_cert_hash')
NODE_NAME=$(hostname)
AVAILABILITY_ZONE=$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
PROVIDER_ID="aws://$AVAILABILITY_ZONE/$INSTANCE_ID"
sudo cat <<EOF | sudo tee cluster-join.yaml
    apiVersion: kubeadm.k8s.io/v1beta3
    kind: JoinConfiguration
    discovery:
      bootstrapToken:
        token: $JOIN_TOKEN
        apiServerEndpoint: ${api_server_endpoint}:${api_server_port}
        caCertHashes:
          - $CA_CERT_HASH
    nodeRegistration:
      name: "$NODE_NAME"
      kubeletExtraArgs:
        node-labels: role=worker
        provider-id: "$PROVIDER_ID"
      taints:
        - effect: NoExecute
          key: node.cilium.io/agent-not-ready
EOF

sudo kubeadm join \
  --v=5 \
      --config cluster-join.yaml
