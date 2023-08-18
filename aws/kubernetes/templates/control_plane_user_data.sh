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
yum update -y || sleep 15 && yum update -y

curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
aws s3api get-object --bucket ${org}-${cluster_name}-cluster-scripts --key kubeadm_init.sh kubeadm_init.sh
chmod +x kubeadm_init.sh

./kubeadm_init.sh \
  --api_port ${api_port} \
  --cgroup_driver ${cgroup_driver} \
  --cluster_cidr ${cluster_cidr} \
  --cluster_name ${cluster_name} \
  --cloud_provider ${cloud_provider} \
  --control_plane_endpoint ${control_plane_endpoint} \
  --kubernetes_version ${kubernetes_version} \
  --kubelet_authorization_mode ${kubelet_authorization_mode} \
  --kubelet_tls_bootstrap_enabled ${kubelet_tls_bootstrap_enabled} \
  --sa_signer_pkcs8_pub ${sa_signer_pkcs8_pub} \
  --sa_signer_key ${sa_signer_key} \
  --service_account_issuer_url ${service_account_issuer_url} \
  --secret_arn ${secret_arn} \
  --region ${region}

aws s3api get-object --bucket ${org}-${cluster_name}-cluster-scripts --key helm_install.sh helm_install.sh
chmod +x helm_install.sh

./helm_install.sh \
  --api_port ${api_port} \
  --asg-name ${asg_name} \
  --aws_load_balancer_controller_enabled ${aws_load_balancer_controller_enabled} \
  --aws_load_balancer_controller_replicas ${aws_load_balancer_controller_replicas} \
  --aws_external_dns_enabled ${aws_external_dns_enabled} \
  --aws_external_dns_replicas ${aws_external_dns_replicas} \
  --aws_access_key_id ${aws_access_key_id} \
  --aws_secret_access_key ${aws_secret_access_key} \
  --availability_zones ${availability_zones} \
  --cert_arns ${cert_arns} \
  --cert_manager_enabled ${cert_manager_enabled} \
  --cilium_version ${cilium_version} \
  --cluster_cidr ${cluster_cidr} \
  --cluster_domain ${cluster_domain} \
  --cluster_name ${cluster_name} \
  --control_plane_endpoint ${control_plane_endpoint} \
  --ebs_csi_driver_enabled ${ebs_csi_driver_enabled} \
  --env ${env} \
  --gateway_domains ${gateway_domains} \
  --github_ssh_secret ${github_ssh_secret} \
  --karpenter_enabled ${karpenter_enabled} \
  --karpenter_instance_profile ${karpenter_instance_profile} \
  --karpenter_replicas ${karpenter_replicas} \
  --karpenter_service_account_role_arn ${karpenter_service_account_role_arn} \
  --karpenter_version ${karpenter_version} \
  --metrics_server_enabled ${metrics_server_enabled} \
  --org ${org} \
  --pod_identity_webhook_enabled ${pod_identity_webhook_enabled} \
  --region_code ${region_code} \
  --ssh_public_key ${ssh_public_key} \
  --cluster_autoscaler_enabled ${cluster_autoscaler_enabled} \
  --region ${region}

# Create namespaces
kubectl create ns "${env}" && \
  kubectl label namespace "${env}" istio-injection=enabled
kubectl create ns database

aws s3api get-object --bucket ${org}-${cluster_name}-cluster-scripts --key create_secrets.sh create_secrets.sh
chmod +x create_secrets.sh

./create_secrets.sh \
  --region ${region} \
  --app_secret_name ${app_secret_name} \
  --beantown_secret_name ${beantown_secret_name} \
  --database_secret_name ${database_secret_name}
