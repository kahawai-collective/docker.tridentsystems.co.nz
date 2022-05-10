# Set the URL for CRAN
old <- getOption("defaultPackages"); r <- getOption("repos")
r["CRAN"] <- "http://cran.stat.auckland.ac.nz"
#r['CRAN'] = 'https://mran.microsoft.com/snapshot/2020-03-25'
options(defaultPackages = c(old, "MASS"), repos = r, warn=2)

packages <- c('tidyverse','tinytex','bookdown')

#update.packages(ask=F)

existing <- tryCatch({
    library()$results[, 'Package']
}, error = function (x) {
    c()
})

pkgs2install <- setdiff(packages, existing)
message(sprintf('Installing packages: %s', paste(pkgs2install, collapse=', ')))

install.packages(pkgs2install)
