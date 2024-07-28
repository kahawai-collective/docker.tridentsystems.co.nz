old <- getOption("defaultPackages"); r <- getOption("repos")
r["CRAN"] <- "http://cran.stat.auckland.ac.nz"
options(defaultPackages = c(old, "MASS"), repos = r)

packages <- c("rstan", "runjags", "rbokeh", "viridis", "loo")
packages <- setdiff(packages, library()$results[,"Package"])

for (p in packages) {
    if (!require(p, character.only=TRUE)) {
        install.packages(p)
    }
}

