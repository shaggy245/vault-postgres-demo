# vault-postgres-demo

Demonstrate Vault's ability to dynamically manage Postgres users via the [Vault Database Secrets Engine](https://developer.hashicorp.com/vault/tutorials/db-credentials/database-secrets).

## Setup

1) `docker compose -f compose.yml up -d`
1) `./vault_init.sh`

## Test
(requires vault and psql)

1) `vault login -method=userpass username=vaultpg password=vaultpg`
1) `vault read database/creds/readonly`
1) `psql 'postgres://127.0.0.1:5432/postgres' -U <dynamic read-only username generated from previous vault command>`

## Teardown
1) `docker compose -f compose.yml down`

## Example
```
➜  vault-postgres git:(main) ✗ docker compose -f compose.yml up -d
[+] Running 3/3
 ✔ Network vault-postgres_default    Created                                                                                                                                                                              0.0s
 ✔ Container vault-postgres-vault-1  Started                                                                                                                                                                              0.3s
 ✔ Container vault-postgres-pg-1     Started                                                                                                                                                                              0.3s
➜  vault-postgres git:(main) ✗ ./vault_init.sh
Create database secrets backend...
Configure postgres secrets plugin...
Create database secrets backend Postgres read-only role...
Create vault poliy allowing access to Postgres readonly role...
Enable userpass auth method...
Create "vaultpg" vault user with access to pg-ro...

➜  vault-postgres git:(main) ✗ vault login -method=userpass username=vaultpg password=vaultpg
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                    Value
---                    -----
token                  hvs.CAESIF0oY2ZcVcdkJNnLaubQDuKErjN1XtD4IZBtTY9BoaYJGh4KHGh2cy5yc1h4dEc2TXZ1bjc3anRBeUNmUDA4M08
token_accessor         93rCYDxlM8Sqq3WkS3OijFK7
token_duration         768h
token_renewable        true
token_policies         ["default" "pg-ro"]
identity_policies      []
policies               ["default" "pg-ro"]
token_meta_username    vaultpg

➜  vault-postgres git:(main) ✗ vault token lookup
Key                 Value
---                 -----
accessor            93rCYDxlM8Sqq3WkS3OijFK7
creation_time       1689289902
creation_ttl        768h
display_name        userpass-vaultpg
entity_id           b17af02a-09a9-74ac-037f-a50870433c21
expire_time         2023-08-14T23:11:42.969923969Z
explicit_max_ttl    0s
id                  hvs.CAESIF0oY2ZcVcdkJNnLaubQDuKErjN1XtD4IZBtTY9BoaYJGh4KHGh2cy5yc1h4dEc2TXZ1bjc3anRBeUNmUDA4M08
issue_time          2023-07-13T23:11:42.969930011Z
meta                map[username:vaultpg]
num_uses            0
orphan              true
path                auth/userpass/login/vaultpg
policies            [default pg-ro]
renewable           true
ttl                 767h59m47s
type                service
➜  vault-postgres git:(main) ✗ vault read database/creds/readonly
Key                Value
---                -----
lease_id           database/creds/readonly/npFlsTHUemR6tbFn1Q7P8oCC
lease_duration     1m
lease_renewable    true
password           pu6mizLAtYXW-ZPZRicg
username           v-userpass-readonly-14kSINd72dQz3ITN5ewY-1689289920

➜  vault-postgres git:(main) ✗ psql 'postgres://127.0.0.1:5432/postgres' -U v-userpass-readonly-14kSINd72dQz3ITN5ewY-1689289920 -c '\conninfo'
Password for user v-userpass-readonly-14kSINd72dQz3ITN5ewY-1689289920:
You are connected to database "postgres" as user "v-userpass-readonly-14kSINd72dQz3ITN5ewY-1689289920" on host "127.0.0.1" at port "5432".

➜  vault-postgres git:(main) ✗ psql postgres://root:root@127.0.0.1:5432 -c '\du'
                                                        List of roles
                      Role name                      |                         Attributes                         | Member of
-----------------------------------------------------+------------------------------------------------------------+-----------
 ro                                                  | No inheritance, Cannot login                               | {}
 root                                                | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 v-userpass-readonly-WCrvaVa0BmiGcxPkfJQZ-1689310466 | Password valid until 2023-07-14 05:54:31+00                | {ro}
 vault                                               | Superuser, No inheritance                                  | {}
```
