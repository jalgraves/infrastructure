#!/bin/bash

ARGS=("$@")
ARG_INDEX=0
for arg in "${ARGS[@]}"; do
  value=$((ARG_INDEX+1))
  case $arg in
    --app_secret_name)
      APP_SECRET_NAME="${ARGS[$value]}"
      ;;
    env)
      ENV="${ARGS[$value]}"
      ;;
    --region)
      REGION="${ARGS[$value]}"
      ;;
    --beantown_secret_name)
      BEANTOWN_SECRET_NAME="${ARGS[$value]}"
      ;;
    --database_secret_name)
      DATABASE_SECRET_NAME="${ARGS[$value]}"
      ;;
  esac
  ((ARG_INDEX=ARG_INDEX+1))
done

echo "region: $REGION"
echo "database_secret_name: $DATABASE_SECRET_NAME"

DB_SECRET=$(aws secretsmanager get-secret-value --region "$REGION" \
  --secret-id "$DATABASE_SECRET_NAME" | jq -r '.SecretString' | jq '.' | jq .
)

cat <<EOF | tee /home/ec2-user/manifests/db-secrets.yaml
apiVersion: v1
data:
  contact_db_name: "$(echo "$DB_SECRET" | jq -r '.contact_db_name' | base64 -w 0)"
  db_admin_pass: "$(echo "$DB_SECRET" | jq -r '.db_admin_pass' | base64 -w 0)"
  db_admin_user: "$(echo "$DB_SECRET" | jq -r '.db_admin_user' | base64 -w 0)"
  db_pass: "$(echo "$DB_SECRET" | jq -r '.db_pass' | base64 -w 0)"
  db_user: "$(echo "$DB_SECRET" | jq -r '.db_user' | base64 -w 0)"
  menu_db_name: "$(echo "$DB_SECRET" | jq -r '.menu_db_name' | base64 -w 0)"
  merch_db_name: "$(echo "$DB_SECRET" | jq -r '.merch_db_name' | base64 -w 0)"
  users_db_name: "$(echo "$DB_SECRET" | jq -r '.users_db_name' | base64 -w 0)"
kind: Secret
metadata:
  name: db-creds
  namespace: database
type: Opaque
EOF

kubectl apply -f /home/ec2-user/manifests/db-secrets.yaml

BEANTOWN_SECRET=$(aws secretsmanager get-secret-value --region "$REGION" \
  --secret-id "$BEANTOWN_SECRET_NAME" | jq -r '.SecretString' | jq '.' | jq .
)

cat <<EOF | tee /home/ec2-user/manifests/beantown-secrets.yaml
apiVersion: v1
data:
  kafka_bootstrap_server: "$(echo "$BEANTOWN_SECRET" | jq -r '.kafka_bootstrap_server' | base64 -w 0)"
  kafka_password: "$(echo "$BEANTOWN_SECRET" | jq -r '.kafka_password' | base64 -w 0)"
  kafka_username: "$(echo "$BEANTOWN_SECRET" | jq -r '.kafka_username' | base64 -w 0)"
  session_secret: "$(echo "$BEANTOWN_SECRET" | jq -r '.session_secret' | base64 -w 0)"
  square_access_token_dev: "$(echo "$BEANTOWN_SECRET" | jq -r '.square_access_token_dev' | base64 -w 0)"
  square_access_token_prod: "$(echo "$BEANTOWN_SECRET" | jq -r '.square_access_token_prod' | base64 -w 0)"
  square_application_id_sandbox: "$(echo "$BEANTOWN_SECRET" | jq -r '.square_application_id_sandbox' | base64 -w 0)"
  square_url: "$(echo "$BEANTOWN_SECRET" | jq -r '.square_url' | base64 -w 0)"
kind: Secret
metadata:
  name: beantown-creds
  namespace: database
type: Opaque
EOF

kubectl apply -f /home/ec2-user/manifests/db-secrets.yaml

APP_SECRET=$(aws secretsmanager get-secret-value --region "$REGION" \
  --secret-id "$APP_SECRET_NAME" | jq -r '.SecretString' | jq '.' | jq .
)

cat <<EOF | tee /home/ec2-user/manifests/app-secrets.yaml
apiVersion: v1
data:
  api_user: "$(echo "$APP_SECRET" | jq -r '.api_user' | base64 -w 0)"
  api_pass: "$(echo "$APP_SECRET" | jq -r '.api_pass' | base64 -w 0)"
  db_host: "$(echo "$APP_SECRET" | jq -r '.db_host' | base64 -w 0)"
  db_pass: "$(echo "$APP_SECRET" | jq -r '.db_pass' | base64 -w 0)"
  db_port: "$(echo "$APP_SECRET" | jq -r '.db_port' | base64 -w 0)"
  db_user: "$(echo "$APP_SECRET" | jq -r '.db_user' | base64 -w 0)"
kind: Secret
metadata:
  name: app-creds
  namespace: "${ENV}"
type: Opaque
EOF
