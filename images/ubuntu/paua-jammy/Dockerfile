FROM docker.kahawai.net.nz/ubuntu/gorbachev-base-jammy
MAINTAINER david@pisces.nz

COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r
RUN Rscript /etc/kahawai-jobserver/r_requirements.r

RUN mkdir -p -v /usr/local/lib/R/site-library/paua.sam
COPY ./COMMON/. /usr/local/lib/R/site-library/paua.sam/
