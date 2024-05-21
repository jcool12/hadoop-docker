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
ENV HIVE_HOME=/opt/hive
ENV PATH=$PATH:$HIVE_HOME/bin:/usr/lib/postgresql/*/bin

# Download and extract Hive
RUN wget https://downloads.apache.org/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    tar -xzf apache-hive-${HIVE_VERSION}-bin.tar.gz -C /opt/ && \
    mv /opt/apache-hive-${HIVE_VERSION}-bin $HIVE_HOME && \
    rm apache-hive-${HIVE_VERSION}-bin.tar.gz

# Copy Hive configuration files
COPY hive-site.xml $HIVE_HOME/conf/

# Expose ports
EXPOSE 10000 10002

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]