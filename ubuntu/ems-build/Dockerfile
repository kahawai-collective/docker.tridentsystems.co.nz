FROM docker.pisces.net.nz/ubuntu/gorbachev-base

MAINTAINER richard@dragonfly.co.nz

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y mysql-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
