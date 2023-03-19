#!/usr/bin/env bash

set -e

IFS=',' read -ra DATABASES <<< "$POSTGRES_MULTIPLE_DATABASES"

echo "${DATABASES[@]}"

for database in "${DATABASES[@]}"; do
    echo "Creating database: $database"
    if [ "$database" == "dev" ]; then
        rm -rf /var/lib/postgresql/dev/PG_15_202209061
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
            CREATE TABLESPACE "$database" LOCATION '/var/lib/postgresql/dev';
            CREATE DATABASE "$database" WITH TABLESPACE="$database";
            GRANT ALL PRIVILEGES ON DATABASE "$database" TO "$POSTGRES_USER";
EOSQL
    else
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
            CREATE DATABASE "$database";
            GRANT ALL PRIVILEGES ON DATABASE "$database" TO "$POSTGRES_USER";
EOSQL
    fi
done
