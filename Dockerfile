FROM node:10.21.0-buster

# Let's start with some basic stuff.
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg \
    gnupg-agent \
    software-properties-common \
    lxc \
    iptables \
    jq

# Add Docker’s official GPG key
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable" && \
    apt-get update && \
    apt-get install containerd.io

RUN wget -q https://download.docker.com/linux/debian/dists/buster/pool/stable/amd64/docker-ce-cli_19.03.11~3-0~debian-buster_amd64.deb && \
    dpkg -i docker-ce-cli_19.03.11~3-0~debian-buster_amd64.deb && \
    rm ./docker-ce-cli_19.03.11~3-0~debian-buster_amd64.deb && \
    wget -q https://download.docker.com/linux/debian/dists/buster/pool/stable/amd64/docker-ce_19.03.11~3-0~debian-buster_amd64.deb && \
    dpkg -i docker-ce_19.03.11~3-0~debian-buster_amd64.deb && \
    rm ./docker-ce_19.03.11~3-0~debian-buster_amd64.deb

RUN set -eux; \
    dind_commit=37498f009d8bf25fbb6199e8ccd34bed84f2874b; \
    dind_file=/usr/local/bin/dind; \
    wget -qO "$dind_file" "https://raw.githubusercontent.com/docker/docker/$dind_commit/hack/dind"; \
    chmod +x "$dind_file"

# RUN set -ex; \
#     mkdir -p /etc/services.d/dind; \
#     printf '#!/usr/bin/execlineb -P\ns6-notifyoncheck -c "docker version"\n/usr/local/bin/dind dockerd' > /etc/services.d/dind/run; \
#     echo '3' > /etc/services.d/dind/notification-fd; \
#     printf '#!/usr/bin/execlineb -S0\ns6-svscanctl -t /var/run/s6/services' > /etc/services.d/dind/finish

# Install google cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk=297.0.1-0 kubectl

# Install the magic wrapper.
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker
# RUN sleep 1000000
# CMD ["bash"]
CMD ["wrapdocker"]
