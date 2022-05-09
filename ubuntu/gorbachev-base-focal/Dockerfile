FROM docker.kahawai.net.nz/ubuntu/texlive-r-focal
MAINTAINER richard@dragonfly.co.nz

RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client \
                                               git-core \
                                               python-pygments \
                                               jags \
                                               gdal-bin \
                                               libudunits2-dev \
                                               libcairo2-dev \
                                               libxt-dev \
                                               libv8-dev \
                                               libssl-dev \
                                               libgmp3-dev \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN apt-get update && \
    apt-get install -y --no-install-recommends r-cran-rstan \
                                               r-cran-tidyverse \
                                               r-cran-shapefiles \
                                               r-cran-sp \
                                               r-cran-lattice \
                                               r-cran-foreign \
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
                                               r-cran-rpart \
                                               r-cran-caret \
                                               r-cran-openxlsx \
                                               r-cran-readxl \
                                               r-cran-gam \
                                               r-cran-mgcv \
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
                                               r-cran-bestglm \
                                               r-cran-arm \
                                               r-cran-ggrepel \
                                               r-cran-truncdist \
                                               r-cran-sf \
                                               r-cran-fields \
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
                                               r-cran-rpostgis \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#                                               r-cran-RColorBrewer \
#                                               r-cran-RPostgreSQL \
#                                               r-cran-gridExtra \
#                                               r-cran-R2jags \
#                                               r-cran-ggspatial \
#                                               r-cran-Cairo \
#                                               r-cran-Matching \
#                                               r-cran-BenfordTests \
#                                               r-cran-gridBase \
#                                               r-cran-beanplot \
#                                               r-cran-tidyxl \
#                                               r-cran-GGally \
#                                               r-cran-timeline \
#                                               r-cran-CheckDigit \
#                                               r-cran-kableExtra \
#                                               r-cran-lunar \
#                                               r-cran-glmmTMB \
#                                               r-cran-PBSmapping \
#                                               r-cran-colorRamps \
#                                               r-cran-tidybayes \
#                                               r-cran-Rcpp \
#                                               r-cran-DHARMa \
#                                               r-cran-MuMIn \
#                                               r-cran-ggExtra \
#                                               r-cran-multimode \
#                                               r-cran-MASS \


#COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r
#RUN Rscript /etc/kahawai-jobserver/r_requirements.r


# TODO: something less fragile
RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub

# RUN apt-add-repository multiverse && apt-get update
# RUN apt-get install -y msttcorefonts
# RUN apt-get install -y pandoc

# COPY fonts/ /usr/local/share/fonts/

# COPY dragonfly-latex-templates_1.13_all.deb /tmp/
# RUN dpkg -i /tmp/dragonfly-latex-templates_1.13_all.deb
# COPY trident-latex-templates_1.6_all.deb /tmp/
# RUN dpkg -i /tmp/trident-latex-templates_1.6_all.deb
# COPY pisces-latex-templates_0.32_all.deb /tmp/
# RUN dpkg -i /tmp/pisces-latex-templates_0.32_all.deb
# COPY mpi-latex-templates_1.31_all.deb /tmp/
# RUN dpkg -i /tmp/mpi-latex-templates_1.31_all.deb
