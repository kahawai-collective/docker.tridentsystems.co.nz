# packages for the paua stock assessments
# and model and MPE diagnostics

install_loc <- "/usr/lib/R/site-library"

# Set the URL for CRAN
cran_nz <- "http://cran.stat.auckland.ac.nz"

packages <- c(
    'hexbin',
    'ggplot2',
    'corpcor',
    'flextable',
    'equatags',
    'reactable',
    'aws.s3',
    'aws.signature',
    'tidyverse',
    'data.table'
)


existing <- tryCatch({
    library()$results[, 'Package']
}, error = function (x) {
    c()
})

pkgs2install <- setdiff(packages, existing)
message(sprintf('Installing packages: %s', paste(pkgs2install, collapse=', ')))
install.packages(pkgs2install,
                 lib = install_loc,
                 repos = c(cran_nz, getOption('repos')))

# for the R Shiny app
install.packages(c('shinydashboard', 'shinycssloaders'),
                 lib = install_loc,
                 repos = c('https://cloud.r-project.org/src/contrib', getOption('repos')),
                 dependencies = TRUE)

# install LB-SPR
devtools::install_github('adrianhordyk/LBSPR', upgrade = 'always')

# RTMB model engine (PAUA-Stock-Assessment-Model/MODEL/RTMB): Laplace fits, SparseNUTS sampling
# and the RTMB diagnostics (posterior summaries, figures).
# TMB and RTMB are built from source so that they match the Matrix package of the image
# (a binary mismatch with Matrix crashed the sparse-Cholesky code on R 4.6 in the opal package).
install.packages(c('TMB', 'RTMB'),
                 lib = install_loc, type = 'source',
                 repos = c('https://cloud.r-project.org', getOption('repos')))
install.packages(c('Matrix', 'posterior', 'patchwork', 'cowplot', 'bayesplot', 'RcppParallel'),
                 lib = install_loc,
                 repos = c('https://cloud.r-project.org', getOption('repos')))
# StanEstimators is the NUTS backend of SparseNUTS; build it from the r-universe source
install.packages('StanEstimators',
                 lib = install_loc, type = 'source',
                 repos = c('https://andrjohns.r-universe.dev', 'https://cloud.r-project.org'))
remotes::install_github('noaa-afsc/SparseNUTS', upgrade = 'never')
# fail the image build if the engine cannot be loaded
for (pkg in c('RTMB', 'TMB', 'SparseNUTS', 'StanEstimators', 'posterior', 'Matrix'))
    stopifnot(requireNamespace(pkg, quietly = TRUE))

# to update ragg
# see https://stackoverflow.com/questions/68753250/getting-the-error-graphics-api-version-mismatch
update.packages(ask = FALSE, checkBuilt = TRUE,
                repos = c('https://cloud.r-project.org/src/contrib', getOption('repos')))
