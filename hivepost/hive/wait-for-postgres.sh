#!/bin/bash

set -e

host="$1"
shift
cmd="$@"

echo "Waiting for PostgreSQL to start at $host..."

# Timeout after 60 attempts (1 minute)
timeout=60
attempt=0

until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$host" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q'; do
  attempt=$((attempt + 1))
  if [ $attempt -ge $timeout ]; then
    >&2 echo "Postgres is still unavailable after $timeout attempts - exiting"
    exit 1
  fi
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - checking for required tables"

# Check for the existence of required tables in Hive metastore database
required_tables=("AUX_TABLE" "BUCKETING_COLS" "CDS" "COLUMNS_V2" "COMPACTION_METRICS_CACHE")
tables_exist=true

for table in "${required_tables[@]}"; do
  if ! PGPASSWORD=$POSTGRES_PASSWORD psql -h "$host" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT to_regclass('public.$table');" | grep -q 'public.'"$table"; then
    tables_exist=false
    break
  fi
done

if ! $tables_exist; then
    >&2 echo "Required tables not found. Proceeding with initialization..."
    # Run initialization steps here if necessary, e.g., schematool
    $HIVE_HOME/bin/schematool -initSchema -dbType postgres || true
else
    >&2 echo "Required tables already exist. Skipping initialization."
fi

>&2 echo "Postgres is up - executing command"
exec $cmd