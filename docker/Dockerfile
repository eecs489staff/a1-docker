# Use the existing mn-stratum image as the base AMD64 image
FROM opennetworking/mn-stratum:20.12

# Update repository URLs to point to archive repositories for Debian Stretch
RUN sed -i 's#http://deb.debian.org/debian#http://archive.debian.org/debian#g' /etc/apt/sources.list && \
    sed -i 's#http://security.debian.org#http://archive.debian.org/debian-security#g' /etc/apt/sources.list

# Install additional packages for AMD64
RUN apt-get update && \
    apt-get install -y \
    iperf \
    iputils-ping \
    build-essential \
    vim \
    emacs \
    gdb \
    traceroute && \
    apt-get clean && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*

# Copy assignment 1 starter code
# COPY src/* /root/assignment1/
COPY modules/* ~/

# Override the entrypoint to prevent Mininet from starting automatically
ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
CMD ["/bin/bash"]
