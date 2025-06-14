FROM postgres:15

RUN apt-get update && apt-get install -y \
    postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

# копирование конфигов
COPY conf/postgresql.conf tmp/postgresql.conf
COPY conf/pg_hba.conf tmp/pg_hba.conf

# создание wal archive
RUN mkdir -p /var/lib/postgresql/wal_archive

# копирование скрипта инициализации
COPY scripts/ /docker-entrypoint-initdb.d/

RUN chmod +x /docker-entrypoint-initdb.d/*sh