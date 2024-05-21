# Use the official Debian 12 image as the base image
FROM debian:12

# Set environment variables for Hadoop and Java
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

# Create a Hadoop user and group
RUN groupadd -r hadoop && useradd -r -g hadoop -d /home/hadoop -m hadoop

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    gnupg2 \
    software-properties-common \
    ssh \
    rsync \
    openssh-server \
    sudo && \
    rm -rf /var/lib/apt/lists/*

# Add the Debian Bullseye repository for OpenJDK 11
RUN echo "deb http://deb.debian.org/debian bullseye main" > /etc/apt/sources.list.d/bullseye.list

# Update and install OpenJDK 11 from the Bullseye repository
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    tar -xzvf hadoop-$HADOOP_VERSION.tar.gz -C /opt && \
    mv /opt/hadoop-$HADOOP_VERSION $HADOOP_HOME && \
    rm hadoop-$HADOOP_VERSION.tar.gz

# Create necessary Hadoop directories and set permissions
RUN mkdir -p /opt/hadoop/dfs/name /opt/hadoop/dfs/data && \
    chown -R hadoop:hadoop /opt/hadoop/dfs && \
    chmod -R 755 /opt/hadoop/dfs

# Set permissions for Hadoop directories
RUN chown -R hadoop:hadoop $HADOOP_HOME

# Copy Hadoop configuration files
COPY core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
COPY hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Set permissions for configuration files
RUN chown hadoop:hadoop $HADOOP_HOME/etc/hadoop/*.xml
RUN chown hadoop:hadoop $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN chmod +x $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Switch to hadoop user
USER hadoop

# Create .ssh directory and configure SSH for Hadoop
RUN mkdir -p /home/hadoop/.ssh && \
    ssh-keygen -t rsa -P "" -f /home/hadoop/.ssh/id_rsa && \
    cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys && \
    chmod 0600 /home/hadoop/.ssh/authorized_keys

# Set JAVA_HOME for the hadoop user
RUN echo "export JAVA_HOME=$JAVA_HOME" >> /home/hadoop/.bashrc && \
    echo "export PATH=$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH" >> /home/hadoop/.bashrc

# Switch back to root to configure SSH server
USER root

# Configure and start SSH server
RUN mkdir /var/run/sshd && \
    echo 'hadoop:hadoop' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config && \
    echo "hadoop ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Expose necessary ports for Hadoop
EXPOSE 50070 8088 22

# Copy entrypoint script into the container
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set entry point
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]