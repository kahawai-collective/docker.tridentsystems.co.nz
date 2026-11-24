FROM docker.kahawai.net.nz/ubuntu/r-resolute

# 2026-11-11: PAUA RTMB image (Ubuntu 26.04) for the RTMB stock-assessment model
# (PAUA-Stock-Assessment-Model/MODEL/RTMB): Laplace fits, simulation-based calibration (SBC),
# SparseNUTS MCMC and model diagnostics (one-step-ahead residuals, posterior summaries, figures).
# Kept small: no TeX Live and no cmdstan installation.
# 2026-11-24: also the packages of the MPE job (PAUA-Stock-Assessment-Model / MPE/shiny/dashboard: launch_remote_MPE.R, launch-mpe-projections.r, tune_funs.R) and of the
# assessment pipeline (ASSESSMENTS/launch-assessment.r), so that one image runs the RTMB assessments with SparseNUTS and the MPE: tidyverse, brms (CPUE model), tidybayes,
# rstan and StanHeaders (the compiled locstan package of the Stan projection dynamics), LBSPR (GitHub; needs gridExtra, plotrix, shiny) and cmdstanr (r-universe), aws.s3, devtools and pkgload, and the C++ tool
# chain for Rcpp::sourceCpp (rules.cpp) and locstan. bakeR (private repository) is not installed, the MPE job does not call it.
# CRAN packages come as r2u binaries (apt r-cran-*), GitHub-only packages are built in
# r_requirements.r.

# CRAN packages as r2u binaries:
#   RTMB engine:      r-cran-rtmb, r-cran-tmb, r-cran-matrix (newer than r-recommended)
#   MCMC:             SparseNUTS' imports (ellipse, microbenchmark, mvtnorm, sparseinv), posterior, loo, and
#                     the compile dependencies of StanEstimators (Rcpp, RcppEigen, BH, RcppParallel,
#                     rapidjsonr). StanEstimators and SparseNUTS are not on r2u (resolute,
#                     2026-11-11) and are built from GitHub in r_requirements.r
#   OSA residuals:    r-cran-rtmbdist (RTMB distributions with OSA support); compResidual
#                     (GitHub) needs TMB and RcppEigen
#   summaries/plots:  ggplot2, patchwork, cowplot, dplyr, tidyr, data.table, digest, rlang
#   GitHub installs:  remotes
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        r-cran-rtmb \
        r-cran-tmb \
        r-cran-matrix \
        r-cran-rcppeigen \
        r-cran-rcpp \
        r-cran-bh \
        r-cran-rcppparallel \
        r-cran-rapidjsonr \
        r-cran-ellipse \
        r-cran-microbenchmark \
        r-cran-mvtnorm \
        r-cran-sparseinv \
        r-cran-posterior \
        r-cran-loo \
        r-cran-rtmbdist \
        r-cran-ggplot2 \
        r-cran-patchwork \
        r-cran-cowplot \
        r-cran-dplyr \
        r-cran-tidyr \
        r-cran-data.table \
        r-cran-digest \
        r-cran-rlang \
        r-cran-remotes \
        build-essential \
        libtbb12 \
        libtbb-dev \
        r-cran-tidyverse \
        r-cran-reshape2 \
        r-cran-abind \
        r-cran-httr \
        r-cran-scales \
        r-cran-brms \
        r-cran-rstan \
        r-cran-stanheaders \
        r-cran-rstantools \
        r-cran-tidybayes \
        r-cran-bayesplot \
        r-cran-aws.s3 \
        r-cran-aws.signature \
        r-cran-devtools \
        r-cran-pkgload \
        r-cran-pkgbuild \
        r-cran-lubridate \
        r-cran-mass \
        r-cran-corpcor \
        r-cran-compositions \
        r-cran-hexbin \
        r-cran-flextable \
        r-cran-reactable \
        r-cran-gridextra \
        r-cran-plotrix \
        r-cran-shiny && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# StanEstimators (NUTS backend of SparseNUTS; compiles the Stan sources, about 20 min) and SparseNUTS, pinned commits,
# in a layer of their own so that it stays cached when r_requirements.r changes
RUN Rscript -e 'remotes::install_github("andrjohns/StanEstimators@7d03a63", lib = "/usr/local/lib/R/site-library", upgrade = "never", dependencies = FALSE)' && \
    Rscript -e 'remotes::install_github("noaa-afsc/SparseNUTS@2f3f162", lib = "/usr/local/lib/R/site-library", upgrade = "never", dependencies = FALSE)' && \
    Rscript -e 'stopifnot(requireNamespace("StanEstimators"), requireNamespace("SparseNUTS"))'

# compResidual (with the OSA_multivariate_dists headers) and a load check of all packages
COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r
RUN Rscript /etc/kahawai-jobserver/r_requirements.r
