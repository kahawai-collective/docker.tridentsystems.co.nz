FROM docker.kahawai.net.nz/r-base/nz
MAINTAINER david@pisces.nz

RUN apt-get update && apt-get install --no-install-recommends -y \
    libcurl4-openssl-dev

COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r

RUN Rscript /etc/kahawai-jobserver/r_requirements.r

# TODO: something less fragile
RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub
