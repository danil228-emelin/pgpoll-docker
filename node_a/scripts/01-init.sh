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

# Создание тестовой базы данных и таблицы
psql -v ON_ERROR_STOP=1 --username postgres --dbname postgres <<-EOSQL
    \c postgres
    CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    item_name VARCHAR(100),
    amount DECIMAL(10,2)
);
BEGIN;

INSERT INTO users (username, email)
VALUES ('alice', 'alice@example.com')
RETURNING user_id;

INSERT INTO orders (user_id, item_name, amount)
VALUES (1, 'Keyboard', 49.99);

COMMIT;

BEGIN;

INSERT INTO users (username, email)
VALUES ('bob', 'bob@example.com')
RETURNING user_id;

INSERT INTO orders (user_id, item_name, amount)
VALUES 
  (2, 'Monitor', 199.99),
  (2, 'Mouse', 25.00);

COMMIT;
EOSQL