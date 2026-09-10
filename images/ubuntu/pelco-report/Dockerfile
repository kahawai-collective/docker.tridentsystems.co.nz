# Build image for the PELCO monthly operational report
# (kahawai-collective/PELCO-reporting, report/).
#
# Built from ubuntu rather than ubuntu/quarto (4.6 GB), which carries TeX Live,
# Chrome and a Jupyter stack the report no longer needs: it renders through
# Typst, which Quarto bundles.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Pacific/Auckland

# R, the geospatial stack sf links against, IBM Plex (the Dragonfly Typst
# template's font family), and git -- the report's build.sh reads the commit hash.
#
# r-recommended matters: r-base-core alone omits R's recommended packages
# (codetools, MASS, Matrix, lattice, ...), which knitr and much of CRAN depend
# on. Without it the first R chunk fails on 'no package called codetools'.
RUN apt-get update && apt-get install -y --no-install-recommends \
      r-base-core r-recommended \
      libgdal34 libgeos-c1v5 libproj25 libudunits2-0 \
      libcurl4 libssl3t64 libxml2 libfontconfig1 \
      libharfbuzz0b libfribidi0 libfreetype6 libpng16-16t64 libtiff6 libjpeg-turbo8 \
      fonts-ibm-plex \
      ca-certificates curl git \
 && fc-cache -f \
 && rm -rf /var/lib/apt/lists/*

# Posit Public Package Manager serves prebuilt binaries for Ubuntu 24.04, so
# these install in seconds instead of compiling, and track current CRAN.
# Ubuntu's own r-cran-* packages are too old for this report: sf 1.0-15 has no
# st_transform.bbox, and patchwork 1.2.0 cannot apply a theme with `&` to a
# ggplot2 4.x plot -- both are used and both would fail the render.
RUN printf '%s\n' \
  'options(repos = c(P3M = "https://packagemanager.posit.co/cran/__linux__/noble/latest"))' \
  'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' \
  >> /usr/lib/R/etc/Rprofile.site

# Only what the report actually loads. ggridges, kableExtra, tidybayes and DBI
# are deliberately absent -- nothing on the built path calls them.
RUN R -q -e 'pkgs <- c("tidyverse","sf","cowplot","patchwork","ggpubr","geosphere", \
                      "RColorBrewer","scales","glue","jsonlite","magrittr", \
                      "knitr","rmarkdown","gt"); \
             install.packages(pkgs); \
             miss <- setdiff(pkgs, rownames(installed.packages())); \
             if (length(miss)) stop("failed to install: ", paste(miss, collapse=", "))'

# The dragonfly-typst Quarto extension declares quarto-required ">=1.8.0".
# Pinned rather than tracking latest, so a rebuild is reproducible.
ARG QUARTO_VERSION=1.10.18
RUN curl -sSL -o /tmp/quarto.deb \
      "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
 && apt-get update && apt-get install -y --no-install-recommends /tmp/quarto.deb \
 && rm -f /tmp/quarto.deb \
 && rm -rf /var/lib/apt/lists/* \
 && quarto --version

# distiller supplies distiller_table(), called from the report's R chunks.
# Vendored here (see DISTILLER_VERSION) because build.py uses this folder as the
# docker context and the kahawai build job has no credentials for the private
# distiller repo. dragonfly.report is not needed: it only installs the Quarto
# extension, and the report repo commits _extensions/.
COPY distiller-r /tmp/distiller-r
RUN R CMD INSTALL /tmp/distiller-r \
 && rm -rf /tmp/distiller-r \
 && R -q -e 'stopifnot(requireNamespace("distiller", quietly=TRUE))'
