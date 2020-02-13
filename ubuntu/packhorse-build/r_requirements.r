old <- getOption("defaultPackages"); r <- getOption("repos")
r["CRAN"] <- "http://cran.stat.auckland.ac.nz"
options(defaultPackages = c(old, "MASS"), repos = r, warn=2)

packages <- c(
    "dplyr", "readxl", "readr", "stringr", "RPostgreSQL"
    # , "aws.s3" # TODO not available for R 3.6.2
)

update.packages(ask=F)

existing <- tryCatch({
    library()$results[, 'Package']
}, error = function (x) {
    c()
})

pkgs2install <- setdiff(packages, existing)
install.packages(pkgs2install)
