FROM docker.tridentsystems.co.nz/ubuntu/gorbachev-base

RUN Rscript -e "install.packages(c('Rcpp','PBSmapping'),repo='http://cran.us.r-project.org/')"

RUN apt-get install -y wget

RUN wget http://get.stenci.la/r/src/contrib/stencila_0.20.tar.gz; \
	R CMD INSTALL stencila_0.20.tar.gz; \
	Rscript -e 'require(stencila); stencila:::install_cli()'; \
	rm stencila_0.20.tar.gz

RUN wget https://github.com/trophia/influ/releases/download/0.9/influ_0.9.tar.gz; \
	R CMD INSTALL influ_0.9.tar.gz; \
	rm influ_0.9.tar.gz
