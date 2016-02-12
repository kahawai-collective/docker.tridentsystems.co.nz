# A Docker image for running https://github.com/trophia/groomer, which apparently does
# "Grooming (and other things!) for New Zealand fisheries catch and effort data", on the
# Kahawai infrastructure. Doesn't need all the R stuff in gorbachev-base so, primarily for build
# speed during development, just using Trusty as a base

FROM ubuntu:14.04

MAINTAINER nokome@trophia.com

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y git python \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/trophia/groomer.git

RUN cd groomer \
  && git pull \
  && git checkout 5565884
