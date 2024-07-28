# Set the URL for CRAN
old <- getOption("defaultPackages"); r <- getOption("repos")
r["CRAN"] <- "http://cran.stat.auckland.ac.nz"
# https://techcommunity.microsoft.com/t5/azure-sql-blog/microsoft-r-application-network-retirement/ba-p/3707161
#r['CRAN'] = 'https://mran.microsoft.com/snapshot/2020-03-25'
options(defaultPackages = c(old, "MASS"), repos = r)

# packages ‘grid’, ‘genoud’, ‘tools’, ‘utils’ are not available (for R version 3.4.2)
# packages ‘lattice’, ‘foreign’, ‘rjson’, ‘MASS’, ‘gam’, ‘timeline’, ‘MuMIn’ are not available (for R version 3.6.3)

packages <- c(
    "shapefiles", "sp", "RColorBrewer",
    "maptools", "RPostgreSQL", "knitr", "pander", "tidyverse",
    "tables", "data.table", "gridExtra", "rjags", "R2jags", "reshape2",
    "mapproj", "cplm", "lme4", 'xtable', 'plyr', 'scales', 'ggspatial',
    'ggmap', 'Cairo', 'maps', 'Matching', 'BenfordTests', 'rgenoud',
    'broom', 'cowplot', 'gridBase', 'pryr', 'proto',
    'beanplot', 'mapdata', 'rpart', 'caret', 'openxlsx', 'readxl', 'tidyxl', 'GGally',
    'mgcv', 'geosphere', 'dbplyr', 'ggforce', 'CheckDigit', 'tinytex',
    'kableExtra', 'fuzzyjoin','lunar','gamlss','glmmTMB','PBSmapping','colorRamps',
    'rstan','brms','patchwork','tidybayes','Rcpp','ggpubr', 'rgdal','party', 'extrafont','viridis','english','coda','runjags',
    'janitor','bestglm','DHARMa','arm','ggrepel','truncdist','sf','fields','raster','glm2','sampling','effects',
    'collapse', 'ggExtra', 'lutz', 'rsample', 'lwgeom', 'multimode',
    'bookdown', 'rpostgis', 'terra', 'stars')

update.packages(ask=F)

existing <- tryCatch({
    library()$results[, 'Package']
}, error = function (x) {
    c()
})

pkgs2install <- setdiff(packages, existing)
message(sprintf('Installing packages: %s', paste(pkgs2install, collapse=', ')))


#old_foreign <- "https://cran.r-project.org/src/contrib/Archive/foreign/foreign_0.8-76.tar.gz"
#install.packages(old_foreign, repos=NULL, type="source")

install.packages(pkgs2install)

old_rgeos <- "https://cran.r-project.org/src/contrib/Archive/rgeos/rgeos_0.3-28.tar.gz"
install.packages(old_rgeos, repos=NULL, type="source")
