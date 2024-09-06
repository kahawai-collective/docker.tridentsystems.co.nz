FROM docker.kahawai.net.nz/ubuntu/gorbachev-base-jammy
MAINTAINER david@pisces.nz

# Does this update R to the most recent version?
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      	libharfbuzz-dev \
        libfribidi-dev \
        r-base-dev \
        r-recommended \
        r-base && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r
RUN Rscript /etc/kahawai-jobserver/r_requirements.r

RUN mkdir -p -v /usr/local/lib/R/site-library/paua.sam
COPY ./COMMON/. /usr/local/lib/R/site-library/paua.sam/
