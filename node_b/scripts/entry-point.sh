#!/bin/bash
set -e

# Проверяем, пуста ли директория PGDATA
if [ -z "$(ls -A $PGDATA)" ]; then
    echo -e "\nPGDATA directory is empty, initializing standby from primary..."
    
    # Ждем доступности primary-сервера
    until pg_isready -h node_a -p 5432 -U replicator; do
        echo "Waiting for primary server to become available..."
        sleep 2
    done
    
    chmod 0750 "$PGDATA"

    # Выполняем базовую копию с primary
    export PGPASSWORD="replicator_pass"
    pg_basebackup -h node_a -p 5432 -U replicator -D "$PGDATA" -v -P --wal-method=stream -R
    
    # Копируем postgresql.conf с проверкой
    if [ -f /tmp/postgresql.conf ]; then
        echo "Копируем конфигурационные файлы postgresql.conf"
        if ! cp /tmp/postgresql.conf "$PGDATA/postgresql.conf"; then
            echo -e "\nERROR: Failed to copy postgresql.conf to $PGDATA/"
            exit 1
        fi
    else
        echo -e "\nERROR: Configuration file postgresql.conf not found in /tmp/"
        exit 1
    fi
    
    # Копируем pg_hba.conf с проверкой
    if [ -f /tmp/pg_hba.conf ]; then
        echo "Копируем конфигурационные файлы pg_hba.conf"
        if ! cp /tmp/pg_hba.conf "$PGDATA/pg_hba.conf"; then
            echo -e "\nERROR: Failed to copy pg_hba.conf to $PGDATA/"
            exit 1
        fi
    else
        echo -e "\nERROR: Configuration file pg_hba.conf not found in /tmp/"
        exit 1
    fi
    
    echo -e "\nStandby initialization complete\n"

    touch "$PGDATA/standby.signal"
    echo "primary_conninfo = 'host=node_a port=5432 user=replicator password=replicator_pass application_name=node_b'" > $PGDATA/postgresql.auto.conf

    echo -e "\nStarting PostgreSQL server..."
    pg_ctl start -D "$PGDATA" -l "$PGDATA/postgres.log"
    tail -f "$PGDATA/postgres.log"
    
else
    echo -e "\nPGDATA directory not empty, starting server with existing data"
    
    # Проверяем наличие standby.signal
    if [ ! -f "$PGDATA/standby.signal" ]; then
        echo -e "\nERROR: standby.signal file not found! This server must run in standby mode."
        echo -e "Please ensure this is a properly configured standby server or clean the PGDATA directory.\n"
        exit 1
    fi
    
    echo -e "\nStarting PostgreSQL server..."
    pg_ctl start -D "$PGDATA" -l "$PGDATA/postgres.log"
    tail -f "$PGDATA/postgres.log"
fi