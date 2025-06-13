FROM postgres:15

# копирование конфигов
COPY conf/postgresql.conf tmp/postgresql.conf
COPY conf/pg_hba.conf tmp/pg_hba.conf

# создание wal archive
RUN mkdir -p /var/lib/postgresql/wal_archive

# копирование скрипта инициализации
#COPY scripts/01-init.sh /docker-entrypoint-initdb.d/

COPY scripts/entry-point.sh /tmp

#RUN chmod +x /docker-entrypoint-initdb.d/*sh && \
RUN  chmod +x /tmp/*sh

# чтобы скрипт смог отработать и запустить кластер
RUN mkdir -p /var/lib/postgresql/data
# Бд будет запускаться в recovery mode
RUN chown postgres:postgres /var/lib/postgresql/data

USER postgres

CMD ["bash", "-c", "/tmp/entry-point.sh"]

