install_loc <- "/usr/lib/R/site-library"

# Non-CRAN packages
remotes::install_github("ropensci/rnaturalearthhires", 
                         lib = install_loc)

remotes::install_github("quantifish/nzsf", 
                         lib = install_loc)
