# Set Hadoop-specific environment variables here.

# The java implementation to use. Required.
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Hadoop Home directory
export HADOOP_HOME=/opt/hadoop

# Add Hadoop bin/ directory to PATH
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

# Hadoop Configuration Directory
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Native Hadoop library path
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"