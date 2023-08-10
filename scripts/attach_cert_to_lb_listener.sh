#!/bin/bash

function attach_cert() {
  echo "Attaching cert to NLB listener $${listener_arn}"
  aws elbv2 modify-listener \
    --region ${aws_region} \
    --listener-arn $${listener_arn} \
    --certificates CertificateArn="arn:aws:iam::${aws_account_id}:server-certificate/${cluster_name}"
}
