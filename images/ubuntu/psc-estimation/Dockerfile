FROM docker.kahawai.net.nz/ubuntu/gorbachev-base-noble
MAINTAINER edward@dragonfly.co.nz

# Duckdb (R package) + qs, arrow for the parquet extract / EM estimand
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        r-cran-duckdb r-cran-qs r-cran-arrow && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Duckdb command-line client.  The database build (duckdb/makefile in
# psc-estimation) pipes its SQL steps into this binary.  Keep the version at
# or below the r-cran-duckdb version so files written by the CLI open in R.
ARG DUCKDB_VERSION=1.4.4
RUN curl -sSL -o /tmp/duckdb_cli.zip \
        https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb_cli-linux-amd64.zip && \
    unzip -o /tmp/duckdb_cli.zip -d /usr/local/bin && \
    chmod a+x /usr/local/bin/duckdb && \
    rm -f /tmp/duckdb_cli.zip && \
    duckdb --version

# PostgreSQL 16 server, run as a TEMPORARY in-job database: the slice dump is
# restored into it, the duckdb extract is built, then it is shut down.
#   postgresql-16            server + contrib (btree_gist, dblink, intarray, pgcrypto)
#   postgresql-16-postgis-3  geometry columns in the dump
#   postgresql-plpython3-16  slice/ephemerides.sql (solar altitude, moon phase)
#   python3-ephem            the pyephem module those functions import
# No "main" cluster is created at install time; the job runs initdb itself as
# the job user into scratch space, so the server binaries are put on PATH.
RUN mkdir -p /etc/postgresql-common && \
    echo "create_main_cluster = false" >> /etc/postgresql-common/createcluster.conf && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        postgresql-16 postgresql-16-postgis-3 postgresql-plpython3-16 python3-ephem && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV PATH=/usr/lib/postgresql/16/bin:${PATH}

# DVC (with the S3 backend): the pipeline jobs pull their inputs from, and push
# their outputs to, the project DVC remote instead of the kahawai OUTPUTDIR.
# Noble blocks system-wide pip installs (PEP 668), so use an isolated venv and
# expose just the CLI on PATH.
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3-venv && \
    python3 -m venv /opt/dvc && \
    /opt/dvc/bin/pip install --no-cache-dir "dvc[s3]" && \
    ln -sf /opt/dvc/bin/dvc /usr/local/bin/dvc && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    dvc --version

# Cmdstan
RUN Rscript -e "install.packages('cmdstanr', repos = c('https://mc-stan.org/r-packages/', getOption('repos')))"
RUN Rscript -e "cmdstanr::install_cmdstan()"

#Slicer packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        r-cran-gridsvg  r-cran-assertthat && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
