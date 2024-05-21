#!/bin/bash

POSTGRES_HOST=postgres

# Start PostgreSQL
until pg_isready -h $POSTGRES_HOST -p 5432 -q; do
  echo "Waiting for PostgreSQL to start..."
  sleep 2
done

# Set HADOOP_HOME
export HADOOP_HOME=/opt/hadoop
export PATH=$HADOOP_HOME/bin:$PATH

# Copy hive-site.xml to Hive conf directory
cp $HIVE_HOME/conf/hive-site.xml $HIVE_HOME/conf/

# Start Hive Metastore
nohup hive --service metastore &

# Start HiveServer2
hive --service hiveserver2