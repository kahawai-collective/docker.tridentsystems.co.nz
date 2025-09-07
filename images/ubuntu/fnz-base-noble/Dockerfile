FROM docker.kahawai.net.nz/ubuntu/r-noble
MAINTAINER david@pisces.nz

RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client \
                                               git-core \
                                               python3-pygments \
                                               gdal-bin \
                                               libssl-dev \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Where available, install required R packages from the deb
# packages provided by r2u
RUN apt-get update && \
    apt-get install -y --no-install-recommends r-cran-tidyverse \
                                               r-cran-sf \
                                               r-cran-devtools \
                                               r-cran-rnaturalearth \
                                               r-cran-rnaturalearthdata \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# For R packages that are not available as deb packages, install from other sources
# RUN mkdir -p -v /usr/local/lib/R/site-library/cmdstan
# ENV CMDSTAN /usr/local/lib/R/site-library/cmdstan
COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r
RUN Rscript /etc/kahawai-jobserver/r_requirements.r
