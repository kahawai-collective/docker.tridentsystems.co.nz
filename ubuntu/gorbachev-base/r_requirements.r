old <- getOption("defaultPackages"); r <- getOption("repos")
r["CRAN"] <- "http://cran.stat.auckland.ac.nz"
options(defaultPackages = c(old, "MASS"), repos = r, warn=2)

# packages ‘grid’, ‘genoud’, ‘tools’, ‘utils’ are not available (for R version 3.4.2)

packages <- c(
    "shapefiles", "foreign", "sp", "lattice", "rgeos", "RColorBrewer",
    "maptools", "RPostgreSQL", "knitr", "rjson", "pander", "tidyverse",
    "tables", "data.table", "gridExtra", "rjags", "R2jags", "reshape2",
    "mapproj", "cplm", "lme4", 'xtable', 'plyr', 'scales', 'rgdal',
    'ggmap', 'Cairo', 'maps', 'Matching', 'BenfordTests', 'rgenoud',
    'broom', 'cowplot', 'MASS', 'gridBase', 'pryr',
    'beanplot', 'mapdata', 'rpart', 'caret', 'openxlsx', 'readxl', 'GGally', 'gam',
    'mgcv', 'geosphere', 'dbplyr', 'timeline', 'ggforce', 'CheckDigit', 'tinytex',
    'kableExtra'
)

update.packages(ask=F)

existing <- tryCatch({
    library()$results[, 'Package']
}, error = function (x) {
    c()
})

#install.packages("INLA", repos=c(getOption("repos"), INLA="https://inla.r-inla-download.org/R/stable"), dep=TRUE)

pkgs2install <- setdiff(packages, existing)
install.packages(pkgs2install)

