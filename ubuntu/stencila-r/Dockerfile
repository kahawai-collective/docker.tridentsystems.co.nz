FROM docker.tridentsystems.co.nz/ubuntu/gorbachev-base

# Install Stencila R package requirements
# Installing Rcpp using 
#	RUN Rscript -e "install.packages('Rcpp',repos='http://cran.us.r-project.org')"
# fails silently for some unknown reason
RUN wget http://cran.r-project.org/src/contrib/Archive/Rcpp/Rcpp_0.11.5.tar.gz; \
	R CMD INSTALL Rcpp_0.11.5.tar.gz; \
	rm Rcpp_0.11.5.tar.gz

# Install Stencila R package
RUN wget http://get.stenci.la/r/complete/x86_64-pc-linux-gnu/3.2/stencila_0.15.1.tar.gz; \
	R CMD INSTALL stencila_0.15.1.tar.gz; \
	Rscript -e 'require(stencila); stencila:::install_cli()'; \
	rm stencila_0.15.1.tar.gz

# Install other R packages not installed by gorbachev-base
RUN wget http://cran.r-project.org/src/contrib/Archive/PBSmapping/PBSmapping_2.68.68.tar.gz; \
	R CMD INSTALL PBSmapping_2.68.68.tar.gz; \
	rm PBSmapping_2.68.68.tar.gz

RUN wget https://github.com/trophia/influ/releases/download/0.9/influ_0.9.tar.gz; \
	R CMD INSTALL influ_0.9.tar.gz; \
	rm influ_0.9.tar.gz
