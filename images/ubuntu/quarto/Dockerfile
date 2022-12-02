FROM docker.kahawai.net.nz/ubuntu/r-jammy

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget \
                                               postgresql-client \
                                               git-core \
                                               python3-pip \
                                               python3-matplotlib && \
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
                                               r-cran-data.table \
                                               r-cran-collapse \
                                               r-cran-proto \
                                               r-cran-gridbase \
                                               r-cran-xtable \
                                               r-cran-janitor \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip3 install --no-cache-dir jupyter

# https://stackoverflow.com/questions/9733338/shell-script-remove-first-and-last-quote-from-a-variable
RUN curl -s https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest \
      | jq -r '.assets[] | select(.name|match("linux-amd64.deb$")) | .browser_download_url' \
      | wget  -P/tmp/ -qi -

RUN dpkg -i /tmp/quarto-*-linux-amd64.deb
RUN  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN quarto install tool tinytex
