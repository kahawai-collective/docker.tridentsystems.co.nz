FROM docker.kahawai.net.nz/ubuntu/texlive-r-jammy
MAINTAINER david@pisces.nz

RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client \
                                               git-core \
                                               python3-pygments \
                                               jags \
                                               gdal-bin \
                                               libudunits2-dev \
                                               libcairo2-dev \
                                               libxt-dev \
                                               libv8-dev \
                                               libssl-dev \
                                               libgmp3-dev \
                                               pandoc \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Where available, install required R packages from the deb
# packages provided by https://launchpad.net/~c2d4u.team
RUN apt-get update && \
    apt-get install -y --no-install-recommends r-cran-rstan \
                                               r-cran-tidyverse \
                                               r-cran-shapefiles \
                                               r-cran-sp \
                                               r-cran-maptools \
                                               r-cran-knitr \
                                               r-cran-rjson \
                                               r-cran-pander \
                                               r-cran-tables \
                                               r-cran-data.table \
                                               r-cran-rjags \
                                               r-cran-reshape2 \
                                               r-cran-mapproj \
                                               r-cran-cplm \
                                               r-cran-lme4 \
                                               r-cran-xtable \
                                               r-cran-plyr \
                                               r-cran-scales \
                                               r-cran-ggmap \
                                               r-cran-maps \
                                               r-cran-rgenoud \
                                               r-cran-broom \
                                               r-cran-cowplot \
                                               r-cran-pryr \
                                               r-cran-proto \
                                               r-cran-mapdata \
                                               r-cran-caret \
                                               r-cran-openxlsx \
                                               r-cran-readxl \
                                               r-cran-gam \
                                               r-cran-geosphere \
                                               r-cran-dbplyr \
                                               r-cran-ggforce \
                                               r-cran-tinytex \
                                               r-cran-fuzzyjoin \
                                               r-cran-gamlss \
                                               r-cran-brms \
                                               r-cran-patchwork \
                                               r-cran-ggpubr \
                                               r-cran-rgdal \
                                               r-cran-party \
                                               r-cran-extrafont \
                                               r-cran-viridis \
                                               r-cran-english \
                                               r-cran-coda \
                                               r-cran-runjags \
                                               r-cran-janitor \
                                               r-cran-arm \
                                               r-cran-ggrepel \
                                               r-cran-truncdist \
                                               r-cran-sf \
                                               r-cran-fields \
                                               r-cran-dbscan \
                                               r-cran-terra \
                                               r-cran-raster \
                                               r-cran-glm2 \
                                               r-cran-sampling \
                                               r-cran-effects \
                                               r-cran-collapse \
                                               r-cran-lutz \
                                               r-cran-rsample \
                                               r-cran-lwgeom \
                                               r-cran-ggnewscale \
                                               r-cran-colorspace \
                                               r-cran-remotes \
                                               r-cran-bookdown \
                                               r-cran-geos \
                                               r-cran-rpostgis \
                                               r-cran-r2jags \
                                               r-cran-ggspatial \
                                               r-cran-cairo \
                                               r-cran-matching \
                                               r-cran-benfordtests \
                                               r-cran-gridbase \
                                               r-cran-ggally \
                                               r-cran-kableextra \
                                               r-cran-glmmtmb \
                                               r-cran-pbsmapping \
                                               r-cran-colorramps \
                                               r-cran-dharma \
                                               r-cran-mumin \
                                               r-cran-ggextra \
                                               r-cran-rcpproll \
                                               r-cran-multimode \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Packages unavailable for jammy (to date):
# r-cran-bestglm \


# For R packages that are not available as deb packages, install from CRAN
RUN mkdir -p -v /usr/local/lib/R/site-library/cmdstan
ENV CMDSTAN /usr/local/lib/R/site-library/cmdstan
COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r
RUN Rscript /etc/kahawai-jobserver/r_requirements.r


# TODO: something less fragile
RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub


RUN apt-add-repository multiverse && apt-get update
# from http://askubuntu.com/a/25614
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
RUN apt-get install -y --no-install-recommends \
       fontconfig \
       ttf-mscorefonts-installer \
       && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY fonts/ /usr/local/share/fonts/

COPY dragonfly-latex-templates_1.13_all.deb /tmp/
RUN dpkg -i /tmp/dragonfly-latex-templates_1.13_all.deb
COPY pisces-latex-templates_0.33_all.deb /tmp/
RUN dpkg -i /tmp/pisces-latex-templates_0.33_all.deb
COPY mpi-latex-templates_1.51_all.deb /tmp/
RUN dpkg -i /tmp/mpi-latex-templates_1.51_all.deb
