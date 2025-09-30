FROM docker.kahawai.net.nz/ubuntu/texlive-r-noble
MAINTAINER david@pisces.nz

RUN apt-get update && \
    apt-get install -y --no-install-recommends cargo \
                                               postgresql-client \
                                               git-core \
                                               python3-pygments \
                                               jags \
                                               gdal-bin \
                                               libudunits2-dev \
                                               libimage-exiftool-perl \
                                               libcairo2-dev \
                                               libxt-dev \
                                               libv8-dev \
                                               libssl-dev \
                                               libgmp3-dev \
                                               libglpk-dev \
                                               pandoc \
                                               fonts-font-awesome \
                                               qpdf \
                                               optipng \
                                               pngquant \
                                               cmake \
                                               p7zip-full \
                                               libavfilter-dev \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Where available, install required R packages from the deb
# packages provided by r2u
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
                                               #r-cran-rgdal \
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
                                               r-cran-flextable \
                                               r-cran-multimode \
                                               r-cran-ggforce \
                                               r-cran-stars \
                                               r-cran-aws.signature \
                                               r-cran-chron \
                                               r-cran-gganimate \
                                               r-cran-magick \
                                               r-cran-gifski \
                                               r-cran-diagrammer \
                                               r-cran-diagrammersvg \
                                               r-cran-rsvg \
                                               r-cran-ncdf4 \
                                               r-cran-rnaturalearth \
                                               r-cran-rnaturalearthdata \
                                               r-cran-devtools \
                                               r-cran-rpart.plot \
                                               r-cran-hexbin \
                                               r-cran-ksgeneral \
                                               r-cran-officer \
                                               r-cran-anytime \
                                               r-cran-ggtext \
                                               r-cran-av \
                                               r-cran-fishmethods \
                                               r-cran-emojifont \
                                               r-cran-ggoceanmaps \
                                               r-cran-icesdatras \
                                               r-cran-tidybayes \
                                               r-cran-posterior \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# # Packages unavailable for jammy (to date):
# # r-cran-bestglm \


# For R packages that are not available as deb packages, install from other sources
# RUN mkdir -p -v /usr/local/lib/R/site-library/cmdstan
# ENV CMDSTAN /usr/local/lib/R/site-library/cmdstan
COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r
RUN Rscript /etc/kahawai-jobserver/r_requirements.r


# # see https://github.com/stan-dev/rstan/issues/1007
# RUN Rscript -e "install.packages(c('BH', 'StanHeaders', 'rstan', 'rstantools', 'brms', 'shinystan', 'Rcpp', 'RcppEigen', 'RcppParallel', 'inline', 'loo', 'pkgbuild'), repos = c('https://mc-stan.org/r-packages/', getOption('repos')))"

# # see https://github.com/JBris/stan-cmdstanr-gpu-docker/blob/main/Dockerfile
# ARG CMDSTAN_VERSION=2.34.1
# RUN cd /usr/local/lib/R/site-library && rmdir cmdstan && \
#     wget --progress dot https://github.com/stan-dev/cmdstan/releases/download/v${CMDSTAN_VERSION}/cmdstan-${CMDSTAN_VERSION}.tar.gz && \
#     tar xzf cmdstan-${CMDSTAN_VERSION}.tar.gz && \
#     mv cmdstan-${CMDSTAN_VERSION} cmdstan && \
#     cd cmdstan && \
#     make build

# RUN Rscript -e "install.packages('cmdstanr', repos = c('https://mc-stan.org/r-packages/', getOption('repos')), dependencies = TRUE)"
# RUN Rscript -e "cmdstanr::check_cmdstan_toolchain() ; cmdstanr::cmdstan_path() ; cmdstanr::cmdstan_version()"


# TODO: something less fragile
RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub

COPY dragonfly-latex-templates_1.13_all.deb /tmp/
RUN dpkg -i /tmp/dragonfly-latex-templates_1.13_all.deb
COPY pisces-latex-templates_0.37_all.deb /tmp/
RUN dpkg -i /tmp/pisces-latex-templates_0.37_all.deb

# This needs to be the version built for noble, from mpi-latex-templates-local
COPY mpi-latex-templates_1.645_all.deb /tmp/
RUN dpkg -i /tmp/mpi-latex-templates_1.645_all.deb

# required for the assessment diagnostics
RUN apt update && \
    apt install -y nodejs && \
    apt install -y node-gyp && \
    apt install -y npm libxslt1-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
