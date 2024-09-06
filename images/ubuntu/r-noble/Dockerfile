FROM docker.kahawai.net.nz/ubuntu/kahawai-noble

# Following approach from https://https://eddelbuettel.github.io/r2u/ as at 5 September 2024

RUN apt update -qq &&  \
    apt install --yes --no-install-recommends ca-certificates gnupg && \
    apt upgrade --yes && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget -q -O- https://eddelbuettel.github.io/r2u/assets/dirk_eddelbuettel_key.asc \
     | tee -a /etc/apt/trusted.gpg.d/cranapt_key.asc

RUN echo "deb [arch=amd64] https://r2u.stat.illinois.edu/ubuntu noble main" \
     > /etc/apt/sources.list.d/cranapt.list
RUN apt update -qq

RUN wget -q -O- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
     | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

RUN echo "deb [arch=amd64] https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" \
     > /etc/apt/sources.list.d/cran_r.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
     67C2D66C4B1D4339 51716619E084DAB9
RUN apt update -qq
RUN DEBIAN_FRONTEND=noninteractive apt install --yes --no-install-recommends \
      r-base-core \
      r-base-dev \
      r-recommended

RUN echo "Package: *" > /etc/apt/preferences.d/99cranapt
RUN echo "Pin: release o=CRAN-Apt Project" >> /etc/apt/preferences.d/99cranapt
RUN echo "Pin: release l=CRAN-Apt Packages" >> /etc/apt/preferences.d/99cranapt
RUN echo "Pin-Priority: 700"  >> /etc/apt/preferences.d/99cranapt

RUN apt install --yes --no-install-recommends python3-dbus python3-gi python3-apt
RUN Rscript -e 'install.packages("bspm")'
#ENV RHOME=$(R RHOME)
ARG RHOME=/usr/lib/R
RUN echo "suppressMessages(bspm::enable())" >> ${RHOME}/etc/Rprofile.site
RUN echo "options(bspm.version.check=FALSE)" >> ${RHOME}/etc/Rprofile.site

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
