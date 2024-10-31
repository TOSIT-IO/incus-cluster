FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    openssh-client \
    jq \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/lxc/incus/releases/download/v6.6.0/bin.linux.incus.x86_64 -O incus

RUN chmod +x incus && mv incus /usr/local/bin/

RUN mkdir /home/tdp

WORKDIR /home/tdp

ENV TDP_HOME=/home/tdp

CMD ["/bin/bash"]
