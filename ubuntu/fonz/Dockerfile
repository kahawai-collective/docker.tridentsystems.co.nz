FROM docker.tridentsystems.co.nz/ubuntu/gorbachev-base
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y python-psycopg2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY r_requirements.r /etc/fonz/r_requirements.r
RUN Rscript /etc/fonz/r_requirements.r
