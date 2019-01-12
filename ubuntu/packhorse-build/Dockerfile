FROM docker.tridentsystems.co.nz/ubuntu/kahawai-build
MAINTAINER david.middleton@tridentsystems.co.nz

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" > /etc/apt/sources.list.d/cran.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        r-base \
        r-base-dev \
        postgresql-client \
        libpq-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

    COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r

    RUN Rscript /etc/kahawai-jobserver/r_requirements.r
