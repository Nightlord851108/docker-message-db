#!/bin/sh
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE account;
    CREATE DATABASE team;
    CREATE USER root;
EOSQL

cd /usr/src/message-db/database
./install.sh
