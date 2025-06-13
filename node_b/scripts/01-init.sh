#!/bin/bash
set -e

# Создание пользователя для репликации
psql -v ON_ERROR_STOP=1 --username postgres --dbname postgres <<-EOSQL
    CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator_pass' LOGIN;
EOSQL

# Создание пользователя для администратора Pgpool
psql -v ON_ERROR_STOP=1 --username postgres --dbname postgres <<-EOSQL
    CREATE USER admin WITH PASSWORD 'admin_pass';
    ALTER USER admin WITH SUPERUSER;
EOSQL


# Создание пользователя для health-чеков
psql -v ON_ERROR_STOP=1 --username postgres --dbname postgres <<-EOSQL
    CREATE USER healthcheck WITH PASSWORD 'healthcheck_pass' LOGIN;
    GRANT SELECT ON pg_catalog.pg_database TO healthcheck;
EOSQL


# подстановка кастомных конфигов и restart сервера
cp /tmp/postgresql.conf $PGDATA/postgresql.conf
cp /tmp/pg_hba.conf $PGDATA/pg_hba.conf

# режим репликации.
touch $PGDATA/standby.signal

pg_ctl restart -D $PGDATA

export PGPASSWORD="replicator_pass"
# Инициализация репликации
pg_basebackup -h node_a -p 5432 -U replicator -v -P --wal-method=stream -D $PGDATA