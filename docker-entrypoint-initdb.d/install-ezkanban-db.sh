#!/bin/sh
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE account;
    CREATE DATABASE team;
    CREATE USER root;
EOSQL

cd /usr/src/message-db/database
./install.sh


psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    \c message_store
    SET search_path TO message_store,public;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    
    create or replace function message_store.notify() returns trigger as
    $BODY$
    begin
    raise notice 'call notify:';
    perform pg_notify('domain_event', CONCAT('{"type":"', NEW."type", '" ,"data":', CAST(NEW."data" as TEXT), '}'));
    return NEW;
    end;
    $BODY$
    language plpgsql;
    
    create or replace trigger messages_trigger
    after insert on message_store.messages
    for each row
    execute procedure message_store.notify();
EOSQL
