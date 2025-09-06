FROM postgres
WORKDIR /database
EXPOSE 5433:5432
COPY init.sql /docker-entrypoint-initdb.d/