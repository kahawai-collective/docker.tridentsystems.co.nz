FROM docker.kahawai.net.nz/ubuntu/r-focal
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get install -y python3-psycopg2 python3-rpy2 librsvg2-bin graphicsmagick pngcrush \
  postgresql-client \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
  apt-get install -y \
  r-cran-cluster \
  r-cran-ggplot2 \
  r-cran-gridextra \
  r-cran-gtools \
  r-cran-mapproj \
  r-cran-maptools \
  r-cran-pbsmapping \
  r-cran-plyr \
  r-cran-proto \
  r-cran-rcolorbrewer \
  r-cran-reshape \
  r-cran-rgdal \
  r-cran-rgeos \
  r-cran-rpostgresql \
  r-cran-scales \
  r-cran-sp \
  postgresql-client \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY install_r /usr/local/bin
RUN install_r beanplot

