# 2026-11-11: compResidual and the package check for the PAUA RTMB image (CRAN packages are r2u binaries,
# installed with apt in the Dockerfile). Commits are pinned so that a rebuild gives the same
# versions as the local tests of 2026-11-11.

install_loc <- "/usr/local/lib/R/site-library"

# StanEstimators and SparseNUTS are installed in their own layer of the Dockerfile (cached, the compile is slow).
# compResidual (fishfollower): one-step-ahead residuals for compositional observations
# Its C++ code includes the OSA_multivariate_dists headers (Trijoulet et al.), which have to be in TMB's include/contrib
# folder first. This is what TMB:::install.contrib(".../archive/main.zip") does (compResidual README); here the commit is
# pinned and the folder given the name the include expects (OSA_multivariate_dists-main).
osa_sha <- "0a1e28c3c0c1723cf436a00c2977cecfcbc0448b"
zf <- tempfile(fileext = ".zip"); ex <- tempfile()
download.file(sprintf("https://github.com/vtrijoulet/OSA_multivariate_dists/archive/%s.zip", osa_sha), zf, quiet = TRUE)
unzip(zf, exdir = ex)
contrib <- file.path(system.file("include", package = "TMB"), "contrib"); dir.create(contrib, showWarnings = FALSE)
stopifnot(file.copy(file.path(ex, paste0("OSA_multivariate_dists-", osa_sha)), contrib, recursive = TRUE),
          file.rename(file.path(contrib, paste0("OSA_multivariate_dists-", osa_sha)), file.path(contrib, "OSA_multivariate_dists-main")))
remotes::install_github("fishfollower/compResidual/compResidual@d4c7484", lib = install_loc, upgrade = "never",
                        dependencies = FALSE)

# 2026-11-24: packages of the MPE job that are not on r2u: LBSPR (length-based SPR, adrianhordyk/LBSPR) and cmdstanr (stan-dev r-universe; the job only uses write_stan_file()
# when it has to build the locstan package, no cmdstan installation is needed for that)
remotes::install_github("adrianhordyk/LBSPR", lib = install_loc, upgrade = "never", dependencies = FALSE)
install.packages("cmdstanr", lib = install_loc, repos = c("https://stan-dev.r-universe.dev", "https://cloud.r-project.org"))

# fail the image build if any package of the RTMB pipeline cannot be loaded
pkgs <- c("RTMB", "TMB", "Matrix", "SparseNUTS", "StanEstimators", "posterior", "loo",
          "RTMBdist", "compResidual", "ggplot2", "patchwork", "cowplot", "dplyr", "tidyr",
          "data.table", "digest", "rlang", "parallel",
          # MPE job (2026-11-24)
          "tidyverse", "reshape2", "abind", "httr", "scales", "brms", "rstan", "StanHeaders", "rstantools", "tidybayes", "bayesplot", "aws.s3", "devtools", "pkgload",
          "pkgbuild", "lubridate", "MASS", "corpcor", "compositions", "LBSPR", "cmdstanr", "Rcpp", "RcppParallel")
ok <- vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)
if (!all(ok)) stop("missing packages: ", paste(pkgs[!ok], collapse = ", "))
print(installed.packages()[pkgs[pkgs != "parallel"], "Version"])
