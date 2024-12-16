FROM alpine:3.19

# Set environment variables for the configuration files and script name
ENV CONFIG_FILE=webdav-server.conf \
    ADDUSER_SCRIPT=adduser.sh

# Install required packages and configure nginx, openssh
RUN set -uex && \
    apk add --no-cache nginx nginx-mod-http-dav-ext nginx-mod-http-headers-more apache2-utils bash dos2unix openssh && \
    ln -sv /dev/stdout /var/log/nginx/access.log && \
    ln -sv /dev/stderr /var/log/nginx/error.log

# Ensure SSH directories exist and create the .ssh directory
RUN mkdir -p /root/.ssh /var/run/sshd && chmod 700 /root/.ssh

# Generate SSH host keys (this is needed for SSHD to start)
RUN ssh-keygen -A

# Copy the authorized_keys file
COPY authorized_keys /root/.ssh/authorized_keys

# Set permissions for the authorized_keys file
RUN chmod 600 /root/.ssh/authorized_keys

# Create the /addusers directory before copying the script
RUN mkdir -p /addusers

# Create the /etc/nginx/snippets/ directory and set appropriate permissions
RUN mkdir -p /etc/nginx/snippets && chmod 755 /etc/nginx/snippets

# Copy the adduser.sh script into the container
COPY adduser.sh /addusers

# Add users by running the script
RUN chmod +x /addusers/adduser.sh && \
    dos2unix /addusers/adduser.sh


