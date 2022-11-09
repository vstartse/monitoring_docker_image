# Pull base image
FROM centos:centos7

# Update CentOS 7
RUN yum update -y && yum upgrade -y

# Install packages
RUN yum install -y unzip

# Clean CentOS 7
RUN yum clean all

# Expose ports
EXPOSE 3100

# Create working directory
WORKDIR /opt/apps/monitor

# Create monitor user
RUN useradd -m -d /opt/apps/monitor monitor

# Copy package files to the image
COPY ./monitor /opt/apps/monitor

# Change ownership of the working dir to monitor user
RUN chown -R monitor.monitor /opt/apps/monitor

# Switch user to monitor
USER monitor

# Define environment variables
ENV K2_HOME=/opt/apps/monitor

# Run init script
CMD [ "sh", "/opt/apps/monitor/init_monitor.sh" ]