#!/bin/bash
VAULT_TOKEN=root
VAULT_ADDR=http://127.0.0.1:8200
VAULT_PG_USER=vault
VAULT_PG_PASS=vault
PG_URL=vault-postgres-pg-1

# Create vault+postgres integration

echo "Create database secrets backend..."
curl --header "X-Vault-Token: $VAULT_TOKEN" \
       --request POST \
       -d '{"type":"database"}' \
       $VAULT_ADDR/v1/sys/mounts/database

echo "Configure Postgres secrets plugin..."
curl --header "X-Vault-Token: $VAULT_TOKEN" \
       --request POST \
       -H "Content-Type: application/json" \
       -d @- \
       $VAULT_ADDR/v1/database/config/postgresql <<EOF
{
  "plugin_name": "postgresql-database-plugin",
  "connection_url": "postgresql://{{username}}:{{password}}@$PG_URL/postgres?sslmode=disable",
  "allowed_roles": "readonly",
  "username": "$VAULT_PG_USER",
  "password": "$VAULT_PG_PASS"
}
EOF

echo "Create database secrets backend read-only role..."
curl --header "X-Vault-Token: $VAULT_TOKEN" \
       --request POST \
       -H "Content-Type: application/json" \
       -d  @- \
       $VAULT_ADDR/v1/database/roles/readonly <<EOF
{
    "db_name": "postgresql",
    "creation_statements": [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT ro TO \"{{name}}\";"
  ],
    "default_ttl": "1h",
    "max_ttl": "24h"
}
EOF

echo "Create vault policy that allows access to Postgres readonly role..."
curl --header "X-Vault-Token: $VAULT_TOKEN" \
       --request POST \
       -H "Content-Type: application/json" \
       -d  '{"policy":"path \"database/creds/readonly\" { capabilities = [\"read\",]} "}' \
       $VAULT_ADDR/v1/sys/policy/pg-ro

# Create vault user that can only generate postgres ro credentials

echo "Enable userpass auth method..."
curl --header "X-Vault-Token: $VAULT_TOKEN" \
       --request POST \
       -d '{"type":"userpass"}' \
       $VAULT_ADDR/v1/sys/auth/userpass <<EOF
EOF

echo "Create \"vaultpg\" vault user with access to pg-ro..."
curl --header "X-Vault-Token: $VAULT_TOKEN" \
       --request POST \
       -d @- \
       $VAULT_ADDR/v1/auth/userpass/users/vaultpg <<EOF
{
    "password": "vaultpg",
    "token_policies": ["pg-ro","default"]
}
EOF
