FROM docker.tridentsystems.co.nz/ubuntu/gorbachev-base
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get install -y python-psycopg2 python-rpy2 librsvg2-bin imagemagick pngcrush \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY r_requirements.r /etc/fonz/r_requirements.r
RUN Rscript /etc/fonz/r_requirements.r
