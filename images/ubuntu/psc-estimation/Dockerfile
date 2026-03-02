FROM docker.kahawai.net.nz/ubuntu/gorbachev-base-noble
MAINTAINER edward@dragonfly.co.nz

# Duckdb
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        r-cran-duckdb  && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

