FROM docker.kahawai.net.nz/ubuntu/r
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get install -y python-psycopg2 python-rpy2 librsvg2-bin imagemagick pngcrush \
  postgresql-client \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY r_requirements.r /etc/fonz/r_requirements.r
RUN Rscript /etc/fonz/r_requirements.r
