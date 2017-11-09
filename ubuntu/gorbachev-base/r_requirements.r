old <- getOption("defaultPackages"); r <- getOption("repos")
r["CRAN"] <- "http://cran.stat.auckland.ac.nz"
options(defaultPackages = c(old, "MASS"), repos = r, warn=2)

packages <- c(
    "shapefiles", "foreign", "sp", "grid", "lattice", "rgeos", "RColorBrewer",
    "maptools", "RPostgreSQL", "knitr", "rjson", "pander", "tidyverse",
    "tables", "data.table", "gridExtra", "rjags", "R2jags", "reshape2",
    "mapproj", "cplm", "lme4", 'xtable', 'plyr', 'scales', 'rgdal',
    'ggmap', 'Cairo', 'maps', 'Matching', 'BenfordTests', 'genoud', 'tools',
    'utils', 'rgenoud', 'broom', 'cowplot', 'MASS', 'gridBase', 'pryr',
    'beanplot', 'mapdata', 'rpart', 'caret', 'openxlsx', 'readxl', 'GGally', 'gam',
    'mgcv', 'geosphere', 'dbplyr', 'timeline', 'ggforce'
)

update.packages(ask=F)

existing <- tryCatch({
    library()$results[, 'Package']
}, error = function (x) {
    c()
})

pkgs2install <- setdiff(packages, existing)
install.packages(pkgs2install)

# INLA has its own repo...
if (!require("INLA", character.only=TRUE)) {
        install.packages("INLA", repos="http://www.math.ntnu.no/inla/R/testing")
    }
