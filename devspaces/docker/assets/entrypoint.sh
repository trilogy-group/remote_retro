#!/bin/bash

# Immediately exits on error
set -o errexit

wait_pg_come_to_life() {
    timer="2"

    until su postgres -c '/usr/lib/postgresql/${PG_VERSION}/bin/pg_isready' 2>/dev/null; do
      >&2 echo "Postgres is unavailable - sleeping for $timer seconds"
      sleep $timer
    done
    echo "Postgres is available"
}

init_user_and_db() {
    # Configure postgres installation dir
    echo "host all  all    0.0.0.0/0  md5" >> ${PG_ETC}/pg_hba.conf && \
    echo "host all  all    ::/0  md5" >> ${PG_ETC}/pg_hba.conf && \
    sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "${PG_ETC}/postgresql.conf"

    # Create pg_data and configure
    su - postgres -c "/usr/lib/postgresql/${PG_VERSION}/bin/initdb -D ${PG_DATA}/"  && \
    echo "host all  all    0.0.0.0/0  md5" >> ${PG_DATA}/pg_hba.conf && \
    echo "host all  all    ::/0  md5" >> ${PG_DATA}/pg_hba.conf && \
    sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "${PG_DATA}/postgresql.conf"

    sv restart postgres

    echo "Creating databases..."

    chpst -u postgres psql -v ON_ERROR_STOP=1 <<-EOSQL
        CREATE USER ${DB_USER}_dev PASSWORD '${DB_PASSWORD}_dev';
        CREATE DATABASE ${DB_NAME}_dev;
        GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME}_dev TO ${DB_USER}_dev;
        GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME}_dev TO PUBLIC;
        ALTER USER ${DB_USER}_dev CREATEDB;
        ALTER DATABASE ${DB_NAME}_dev OWNER TO ${DB_USER}_dev;

        CREATE USER ${DB_USER}_test PASSWORD '${DB_PASSWORD}_test';
        CREATE DATABASE ${DB_NAME}_test;
        GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME}_test TO ${DB_USER}_test;
        GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME}_test TO PUBLIC;
        ALTER USER ${DB_USER}_test CREATEDB;
        ALTER DATABASE ${DB_NAME}_test OWNER TO ${DB_USER}_test;
EOSQL
}

# main:
#   - initialize runit service
#   - waits for postgres to start
#   - creates DB
main() {
    # Startup managed services in background
    /sbin/my_init &

    wait_pg_come_to_life

    init_user_and_db

    # blocks container termination
    tail -f /dev/null
}

#Execute main routine with environment vars
main "$@"
