old <- getOption("defaultPackages"); r <- getOption("repos")
r["CRAN"] <- "http://cran.stat.auckland.ac.nz"
options(defaultPackages = c(old, "MASS"), repos = r)

remove.packages(c("StanHeaders","rstan",'RcppEigen','RcppParallel'))

options(repos = "https://cloud.r-project.org/")
install.packages("remotes")
remotes::install_git('https://github.com/RcppCore/RcppParallel')
install.packages("StanHeaders", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
install.packages("rstan", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
