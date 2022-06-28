FROM docker.kahawai.net.nz/ubuntu/r-bleedingedge

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget \
                                               postgresql-client \
                                               git-core && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && \
    apt-get install -y --no-install-recommends r-cran-jsonlite \
                                               r-cran-rmarkdown \
                                               r-cran-tidyverse \
                                               r-cran-kableextra \
                                               r-cran-patchwork \
                                               r-cran-ggpubr \
                                               r-cran-english \
                                               r-cran-cowplot \
                                               r-cran-sf \
                                               r-cran-glm2 \
                                               r-cran-raster \
                                               r-cran-rpostgis \
                                               r-cran-scales \
                                               r-cran-lwgeom \
                                               r-cran-ggrepel \                                                                                              
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Following https://unix.stackexchange.com/a/7653
RUN wget -q -P/tmp/ https://github.com$(wget -O- -q https://github.com/quarto-dev/quarto-cli/releases/latest | sed -ne 's/^.*"\([^"]*quarto[^"]*linux-amd64\.deb\)".*/\1/p')
RUN dpkg -i /tmp/quarto-*-linux-amd64.deb
RUN  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
