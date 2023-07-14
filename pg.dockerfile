FROM postgres:15.2
ENV POSTGRES_USER=root
ENV POSTGRES_PASSWORD=root
ENV blah=bar
COPY pg_init.sh /docker-entrypoint-initdb.d/pg_init.sh
RUN chmod +x /docker-entrypoint-initdb.d/pg_init.sh
