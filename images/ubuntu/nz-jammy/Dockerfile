FROM ubuntu:22.04
MAINTAINER david@pisces.nz

# Set timezone & locale

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y tzdata locales && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "Pacific/Auckland" > /etc/timezone
RUN ln -fs /usr/share/zoneinfo/Pacific/Auckland /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

RUN locale-gen en_NZ.UTF-8
RUN dpkg-reconfigure locales

ENV LANG en_NZ.UTF-8
ENV LANGUAGE en_NZ:en

ENV TZ="Pacific/Auckland"

# vim: syntax=Dockerfile
# creates a user that will write file that are group writable
# in the dragonfly group. Also can run as sudo
RUN groupadd -r -g 14000 df && useradd -m -r -g df -u 15999 df
USER df:df
RUN echo "umask 002" >> $HOME/.bashrc
RUN echo "umask 002" >> $HOME/.profile
USER root

RUN usermod -a -G sudo df
RUN echo '%sudo	ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
