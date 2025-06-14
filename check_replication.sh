#!/bin/bash

PGPASSWORD=${PGPASSWORD:-"postgres"}
export PGPASSWORD

check_replication_status() {
    local node=$1
    echo "Checking replication status on $node..."
    docker exec $node psql -U postgres -c "SELECT client_addr, state, sync_state
        FROM pg_stat_replication;" | cat
}

# Функция для тестирования репликации
test_replication() {
    local node=$1
    echo "Testing replication on $node..."
    
    docker exec $node psql -t -U postgres -c "
        INSERT INTO users (username, email)
        VALUES ('peter', 'peter@example.com');
    "
    
    for n in node_a node_b node_c; do
        echo "Checking data on $n..."
        docker exec $n psql -t -U postgres -c "
            SELECT * FROM users;
        "
    done

    docker exec $node psql -t -U postgres -c "
        DELETE FROM users WHERE username = 'peter' AND email = 'peter@example.com';
    "
}

echo "Starting replication check..."

echo -e "\n=== Replication Status ==="
check_replication_status node_a
check_replication_status node_b
check_replication_status node_c

echo -e "\n=== Testing Replication ==="
test_replication node_a

echo -e "\nReplication check completed." 
