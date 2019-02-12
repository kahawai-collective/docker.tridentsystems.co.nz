# A Docker image for running various Trophia tools for the analysis
# and reporting of catch and effort data:
#  - groomer : https://github.com/trophia/groomer
#  - influ : https://github.com/trophia/influ

FROM docker.tridentsystems.co.nz/ubuntu/gorbachev-base

MAINTAINER nokome@trophia.com

# Linux packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get install -y python-psycopg2 python-dateutil libgit2-dev libssh2-1-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# devtools 1.13
RUN Rscript -e "options(warn=2); install.packages(c('proto','memoise','git2r'), repo='http://cran.us.r-project.org/')"
RUN Rscript -e "options(warn=2); install.packages('https://cran.r-project.org/src/contrib/Archive/devtools/devtools_1.13.6.tar.gz', repos=NULL, type='source')"

# groomer
RUN git clone https://github.com/trophia/groomer.git

# influ
RUN curl -OL https://github.com/trophia/influ/releases/download/0.9/influ_0.9.tar.gz ;\
	R CMD INSTALL influ_0.9.tar.gz ;\
	rm influ_0.9.tar.gz

# analyser
RUN Rscript -e "options(warn=2); devtools:::install_github('trophia/analyser', ref='a82c5b4')"

# Stencila
RUN curl -OL http://get.stenci.la/r/src/contrib/stencila_0.21.tar.gz ;\
	R CMD INSTALL stencila_0.21.tar.gz ;\
	Rscript -e 'options(warn=2); require(stencila); stencila:::install_cli()' ;\
	rm stencila_0.21.tar.gz

# Update groomer to a particular commit
RUN cd groomer \
  && git pull \
  && git checkout e831dd5
