FROM docker.kahawai.net.nz/ubuntu/kahawai-resolute

# Following approach from https://eddelbuettel.github.io/r2u/ as at 11 August 2026
# Also see https://github.com/eddelbuettel/r2u/blob/master/inst/scripts/add_cranapt_resolute.sh
# and https://cloud.r-project.org/bin/linux/ubuntu/

RUN apt update -qq &&  \
    apt install --yes --no-install-recommends ca-certificates gnupg software-properties-common dirmngr && \
    apt upgrade --yes && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/r2u.gpg --keyserver keyserver.ubuntu.com --recv-keys A1489FE2AB99A21A 67C2D66C4B1D4339 51716619E084DAB9 F2B6E89C389782D0 5E25F516B04C661B
RUN gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/r2u.gpg --export --armor A1489FE2AB99A21A > /etc/apt/trusted.gpg.d/eddelbuettel.asc
RUN gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/r2u.gpg --export --armor F2B6E89C389782D0 5E25F516B04C661B > /etc/apt/trusted.gpg.d/rutter.asc

RUN echo "Types: deb" > /etc/apt/sources.list.d/r2u.sources
RUN echo "URIs: http://r2u.stat.illinois.edu/ubuntu" >> /etc/apt/sources.list.d/r2u.sources
RUN echo "Suites: resolute" >> /etc/apt/sources.list.d/r2u.sources
RUN echo "Components: main" >> /etc/apt/sources.list.d/r2u.sources
RUN echo "Arch: amd64, arm64" >> /etc/apt/sources.list.d/r2u.sources
RUN echo "Signed-By: /etc/apt/trusted.gpg.d/eddelbuettel.asc" >> /etc/apt/sources.list.d/r2u.sources

RUN add-apt-repository  "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

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
