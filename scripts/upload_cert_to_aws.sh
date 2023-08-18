#!/bin/bash

function upload_cert() {
  cert_name="${cluster_name}-$(date +%h-%d-%Y-%H%M)"
  aws iam upload-server-certificate \
    --region ${region} \
    --server-certificate-name "$cert_name" \
    --certificate-body file://"/etc/kubernetes/pki/apiserver.crt" \
    --private-key file://"/etc/kubernetes/pki/apiserver.key"
}

if ! upload_cert; then
  echo "Exit stat $? upload_cert"
fi
