#!/bin/bash

# Remove the slf4j-reload4j-1.7.36.jar file to avoid SLF4J multiple bindings issue
rm /opt/hadoop/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar

# Ensure log4j.properties is in place for Hadoop and Hive
if [ ! -f $HADOOP_CONF_DIR/log4j.properties ]; then
  cp $HADOOP_HOME/conf/log4j.properties $HADOOP_CONF_DIR/log4j.properties
fi

if [ ! -f $HIVE_HOME/conf/log4j.properties ]; then
  cp $HIVE_HOME/conf/log4j-hive.properties $HIVE_HOME/conf/log4j.properties
fi

# Wait for PostgreSQL to be ready
/usr/local/bin/wait-for-postgres.sh postgres

# Check if required tables exist and skip initialization if they do
psql -h postgres -U $POSTGRES_USER -d $POSTGRES_DB -c "\dt" | grep -qw "BUCKETING_COLS"
if [ $? -ne 0 ]; then
  echo "Initializing Hive schema..."
  $HIVE_HOME/bin/schematool -initSchema -dbType postgres
else
  echo "Required tables already exist. Skipping initialization."
fi

# Stop any running HiveServer2 instances
pid=$(pgrep -f 'hive.*service.*hiveserver2')
if [ -n "$pid" ]; then
  echo "Stopping running HiveServer2 process..."
  kill -9 $pid
fi

# Start Hive metastore
$HIVE_HOME/bin/hive --service metastore &

# Start HiveServer2
$HIVE_HOME/bin/hive --service hiveserver2