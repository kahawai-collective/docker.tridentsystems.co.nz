FROM docker.kahawai.net.nz/ubuntu/r-jammy

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget \
                                               postgresql-client \
                                               git-core \
                                               python3-pip \
                                               python3-matplotlib \
                                               python3-sklearn \
                                               libxshmfence-dev \
                                               dumb-init \
                                               nodejs \
                                               npm \
                                               ghostscript && \
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
                                               r-cran-reticulate \
                                               r-cran-chron \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Following https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#running-puppeteer-in-docker per https://quarto.org/docs/authoring/diagrams.html#chrome-install
# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Requires dumb-init package loaded above: https://github.com/Yelp/dumb-init
RUN apt-get update \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir jupyter

# https://stackoverflow.com/questions/9733338/shell-script-remove-first-and-last-quote-from-a-variable
RUN curl -s https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest \
      | jq -r '.assets[] | select(.name|match("linux-amd64.deb$")) | .browser_download_url' \
      | wget  -P/tmp/ -qi -

RUN dpkg -i /tmp/quarto-*-linux-amd64.deb
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN quarto install tool tinytex --quiet


# For converting revealjs to PDF: https://github.com/astefanutti/decktape (requires nodejs and npm installed above)
RUN npm install -g decktape

# Lightbox: https://github.com/biati-digital/glightbox
RUN npm install -g glightbox

RUN quarto install extension quarto-ext/lightbox --no-prompt
