#!/bin/bash
echo "Started failover process...:"

PGDATA_PATH=$1
NEW_MASTER_HOST=$2
NEW_MASTER_PORT=$3
export PGPASSWORD=postgres

psql -h $NEW_MASTER_HOST -p $NEW_MASTER_PORT -U postgres -d postgres -c "SELECT pg_promote();"
echo "Finished failover process.|."
