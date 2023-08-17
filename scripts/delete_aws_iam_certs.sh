#!/bin/bash

for i in $(aws-vault exec "${1}" -- aws iam --region us-east-2 list-server-certificates | jq '.ServerCertificateMetadataList[] | {ServerCertificateName}[]' | tr -d '"'); do \
  aws-vault exec "${1}" -- aws iam delete-server-certificate --region us-east-2  --server-certificate-name "${i}"; \
done
