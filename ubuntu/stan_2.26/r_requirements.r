old <- getOption("defaultPackages"); r <- getOption("repos")
r["CRAN"] <- "http://cran.stat.auckland.ac.nz"
options(defaultPackages = c(old, "MASS"), repos = r)

remotes::install_github("stan-dev/cmdstanr")
install.packages("brms")

