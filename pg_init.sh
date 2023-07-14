#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 -U root -c "CREATE ROLE \"ro\" NOINHERIT;"
psql -v ON_ERROR_STOP=1 -U root -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"ro\";"
psql -v ON_ERROR_STOP=1 -U root -c "CREATE ROLE \"vault\" WITH LOGIN SUPERUSER PASSWORD 'vault' NOINHERIT;"
