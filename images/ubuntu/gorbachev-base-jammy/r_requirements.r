
install_loc <- "/usr/lib/R/site-library"

# cmdstan_install_loc <- Sys.getenv("CMDSTAN")
# remotes::install_version("cmdstanr", repos = "https://mc-stan.org/r-packages/", lib = install_loc, version = '0.5.3')
# cmdstanr::install_cmdstan(dir = cmdstan_install_loc)

system("apt remove -y libtbb2")

# Set the URL for CRAN
cran_nz <- "http://cran.stat.auckland.ac.nz"

packages <- c(
    'beanplot',
    'tidyxl',
    'timeline',
    'CheckDigit',
    'lunar',
    'tidybayes',
    'brms',
    'StanHeaders',
    'posterior',
    'aws.s3',
    'emojifont',
    'transformr',
    'diagrammer',
    'gifski',
    'nngeo',
    'tidyterra',
    'parallel'
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
                 repos = cran_nz)


# Non-CRAN packages
remotes::install_github('clauswilke/multiscales',
                        lib = install_loc)

devtools::install_github("lifewatch/sdmpredictors", 
                         lib = install_loc)

remotes::install_github("ropensci/rnaturalearthhires", 
                         lib = install_loc)

# install CmdStanR
# see https://github.com/stan-dev/cmdstanr/issues/695

existing[grep('[sS]tan', existing)]

# cmdstan_install_loc <- Sys.getenv("CMDSTAN")
# cmdstan_install_loc

# dir.create(cmdstan_install_loc, showWarnings = FALSE)

# install.packages("cmdstanr",
#                  repos = c("https://mc-stan.org/r-packages/"))

# library(cmdstanr)

# cmdstanr::check_cmdstan_toolchain()

# cmdstanr::install_cmdstan(dir = cmdstan_install_loc)

# cmdstanr::cmdstan_path()
# cmdstanr::cmdstan_version()
