old <- getOption("defaultPackages"); r <- getOption("repos")
r["CRAN"] <- "http://cran.stat.auckland.ac.nz"
options(defaultPackages = c(old, "MASS"), repos = r, warn=2)

# packages ‘grid’, ‘genoud’, ‘tools’, ‘utils’ are not available (for R version 3.4.2)

packages <- c(
    "shapefiles", "foreign", "sp", "lattice", "RColorBrewer",
    "maptools", "RPostgreSQL", "knitr", "rjson", "pander", "tidyverse",
    "tables", "data.table", "gridExtra", "rjags", "R2jags", "reshape2",
    "mapproj", "cplm", "lme4", 'xtable', 'plyr', 'scales',
    'ggmap', 'Cairo', 'maps', 'Matching', 'BenfordTests', 'rgenoud',
    'broom', 'cowplot', 'MASS', 'gridBase', 'pryr',
    'beanplot', 'mapdata', 'rpart', 'caret', 'openxlsx', 'readxl', 'GGally', 'gam',
    'mgcv', 'geosphere', 'dbplyr', 'timeline', 'ggforce', 'CheckDigit', 'tinytex',
    'kableExtra', 'fuzzyjoin','lunar','gamlss','glmmTMB','PBSmapping','colorRamps',
    'rstan','brms','Rcpp','ggpubr', 'rgdal'
)

update.packages(ask=F)

existing <- tryCatch({
    library()$results[, 'Package']
}, error = function (x) {
    c()
})

pkgs2install <- setdiff(packages, existing)
install.packages(pkgs2install)

old_rgeos <- "https://cran.r-project.org/src/contrib/Archive/rgeos/rgeos_0.3-28.tar.gz"
install.packages(old_rgeos, repos=NULL, type="source")
