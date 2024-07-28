# Set the URL for CRAN
cran_nz <- "http://cran.stat.auckland.ac.nz"

packages <- c(
    'beanplot',
    'tidyxl',
    'timeline',
    'CheckDigit',
    'lunar',
    'tidybayes',
    'multimode')


existing <- tryCatch({
    library()$results[, 'Package']
}, error = function (x) {
    c()
})

pkgs2install <- setdiff(packages, existing)
message(sprintf('Installing packages: %s', paste(pkgs2install, collapse=', ')))
install.packages(pkgs2install,
                 repos = cran_nz)


# Non-CRAN packages
remotes::install_github('clauswilke/multiscales')
