# A Docker image for running various Trophia tools for the analysis
# and reporting of catch and effort data:
#  - groomer : https://github.com/trophia/groomer
#  - influ : https://github.com/trophia/influ

FROM docker.tridentsystems.co.nz/ubuntu/gorbachev-base

MAINTAINER nokome@trophia.com

# Linux packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y git python python-psycopg2 python-dateutil postgresql-client \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# groomer
RUN git clone https://github.com/trophia/groomer.git

# R packages
RUN Rscript -e "install.packages(c('Rcpp','PBSmapping'),repo='http://cran.us.r-project.org/')"

# influ
RUN curl -OL https://github.com/trophia/influ/releases/download/0.9/influ_0.9.tar.gz; \
	R CMD INSTALL influ_0.9.tar.gz; \
	rm influ_0.9.tar.gz

# Stencila for reporting
RUN curl -OL http://get.stenci.la/r/src/contrib/stencila_0.20.tar.gz; \
	R CMD INSTALL stencila_0.20.tar.gz; \
	Rscript -e 'require(stencila); stencila:::install_cli()'; \
	rm stencila_0.20.tar.gz

# Update groomer to a particular commit
RUN cd groomer \
  && git pull \
  && git checkout e831dd5
