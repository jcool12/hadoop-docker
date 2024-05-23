# Dockerfile for Apache Hive

FROM openjdk:8-jdk

# Install necessary tools
RUN apt-get update && apt-get install -y \
    wget \
    procps \
    net-tools \
    lsof \
    vim \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV HIVE_VERSION=4.0.0
ENV HADOOP_VERSION=3.3.6
ENV HIVE_HOME=/opt/hive
ENV HADOOP_HOME=/opt/hadoop
ENV POSTGRES_JDBC_VERSION=42.2.24
ENV PATH=$PATH:$HIVE_HOME/bin:$HADOOP_HOME/bin:/usr/lib/postgresql/*/bin

# Download and extract Hive
RUN wget https://downloads.apache.org/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    tar -xzf apache-hive-${HIVE_VERSION}-bin.tar.gz -C /opt/ && \
    mv /opt/apache-hive-${HIVE_VERSION}-bin $HIVE_HOME && \
    rm apache-hive-${HIVE_VERSION}-bin.tar.gz

# Download and extract Hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz -C /opt/ && \
    mv /opt/hadoop-${HADOOP_VERSION} $HADOOP_HOME && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

# Create Hadoop configuration directory and add log4j.properties
RUN mkdir -p $HADOOP_HOME/conf
COPY log4j-hadoop.properties $HADOOP_HOME/conf/log4j.properties

# Download PostgreSQL JDBC driver
RUN wget https://jdbc.postgresql.org/download/postgresql-${POSTGRES_JDBC_VERSION}.jar -P /opt/hive/lib/

# Copy Hive configuration files
COPY hive-site.xml $HIVE_HOME/conf/
COPY log4j-hive.properties $HIVE_HOME/conf/log4j.properties

# Copy the wait script
COPY wait-for-postgres.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wait-for-postgres.sh

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 10000 10002

ENTRYPOINT ["/entrypoint.sh"]