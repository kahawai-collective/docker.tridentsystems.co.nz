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
    'reactable'
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
install.packages('shinydashboard',
                 lib = install_loc,
                 repos = c('https://cloud.r-project.org/src/contrib', getOption('repos')),
                 dependencies = TRUE)

# to update ragg
# see https://stackoverflow.com/questions/68753250/getting-the-error-graphics-api-version-mismatch
update.packages(ask = FALSE, checkBuilt = TRUE,
                repos = c('https://cloud.r-project.org/src/contrib', getOption('repos')))
