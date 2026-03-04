FROM docker.kahawai.net.nz/ubuntu/gorbachev-base-noble
MAINTAINER edward@dragonfly.co.nz

# Duckdb
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        r-cran-duckdb  r-cran-qs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Cmdstan 
RUN Rscript -e "install.packages('cmdstanr', repos = c('https://mc-stan.org/r-packages/', getOption('repos')))"
RUN Rscript -e "cmdstanr::install_cmdstan()"
