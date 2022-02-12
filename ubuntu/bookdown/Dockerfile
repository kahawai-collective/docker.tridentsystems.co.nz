FROM docker.kahawai.net.nz/ubuntu/pisces-focal
MAINTAINER david@pisces.nz

RUN apt-get update && apt-get install --no-install-recommends -y \
    postgresql-client \
    git-core \
    build-essential \
    libpng-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    netbase \
    r-base \
    pandoc \
    pandoc-citeproc \
    pandoc-citeproc-preamble


COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r

RUN Rscript /etc/kahawai-jobserver/r_requirements.r

RUN Rscript -e "tinytex::install_tinytex()"

# TODO: something less fragile
RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub
