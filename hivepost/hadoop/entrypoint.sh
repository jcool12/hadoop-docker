#!/bin/bash

# Stop existing Hadoop services if they are running
sudo -u hadoop $HADOOP_HOME/sbin/stop-dfs.sh
sudo -u hadoop $HADOOP_HOME/sbin/stop-yarn.sh

# Remove stale PID files
rm -f /tmp/hadoop-hadoop-namenode.pid
rm -f /tmp/hadoop-hadoop-secondarynamenode.pid

# Start SSH
if ! service ssh status >/dev/null 2>&1; then
    service ssh start
fi

# Ensure SSH is running before proceeding
while ! service ssh status >/dev/null 2>&1; do
    sleep 1
done

# Switch to hadoop user to start Hadoop services
su - hadoop <<EOF

# Set Hadoop and YARN environment variables
export HDFS_NAMENODE_USER=hadoop
export HDFS_DATANODE_USER=hadoop
export HDFS_SECONDARYNAMENODE_USER=hadoop
export YARN_RESOURCEMANAGER_USER=hadoop
export YARN_NODEMANAGER_USER=hadoop

# Ensure Hadoop logs directory exists
mkdir -p /opt/hadoop/logs
chown -R hadoop:hadoop /opt/hadoop/logs

# Format HDFS namenode (if necessary)
if [ ! -d "/opt/hadoop/dfs/name/current" ]; then
    $HADOOP_HOME/bin/hdfs namenode -format
fi

# Start Hadoop services
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

EOF

# Keep the container running
tail -f /dev/null