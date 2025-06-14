FROM bitnami/pgpool:latest

# Копирование конфигурации
COPY conf/custom.conf /opt/bitnami/pgpool/conf/custom.conf

COPY scripts/failover.sh /opt/bitnami/scripts/