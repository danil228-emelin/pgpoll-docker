FROM postgres:15

# копирование конфигов
COPY conf/postgresql.conf tmp/postgresql.conf
COPY conf/pg_hba.conf tmp/pg_hba.conf

# копирование скрипта инициализации
COPY scripts/ /docker-entrypoint-initdb.d/

RUN chmod +x /docker-entrypoint-initdb.d/*sh