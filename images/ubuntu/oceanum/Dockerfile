FROM docker.kahawai.net.nz/ubuntu/gorbachev-base-jammy
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget python3-pip python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN pip3 install --upgrade pip setuptools wheel
RUN pip install oceanum pyreadr rpy2
RUN apt autoremove -y

RUN Rscript -e "install.packages(c('dismo','gbm','terra','suncalc','sf'))"
RUN Rscript -e "install.packages('INLA',repos=c(getOption('repos'),INLA='https://inla.r-inla-download.org/R/stable'), dep=TRUE)"
RUN Rscript -e "install.packages('inlabru')"

