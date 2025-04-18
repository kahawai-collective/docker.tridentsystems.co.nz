old <- getOption("defaultPackages"); r <- getOption("repos")
r["CRAN"] <- "http://cran.stat.auckland.ac.nz"
options(defaultPackages = c(old, "MASS"), repos = r, warn=2)

packages <- c(
    "cluster", "gtools", "PBSmapping", "ggplot2", "mapproj", "reshape", "plyr",
    "proto", "beanplot", "scales", "gridExtra", "RColorBrewer", "RPostgreSQL",
    "sp", "rgeos", "rgdal", "maptools")

existing <- tryCatch({
    library()$results[, 'Package']
}, error = function (x) {
    c()
})

pkgs2install <- setdiff(packages, existing)
install.packages(pkgs2install)
