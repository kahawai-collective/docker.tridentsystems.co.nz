FROM docker.kahawai.net.nz/ubuntu/quarto

RUN Rscript -e 'options(warn=2);remotes::install_github("dragonfly-science/generalised_influ@beaaaaa")'

# Create the target directory inside the container
RUN mkdir -p /usr/local/share/fonts/FNZ

# Copy your local .ttf or .otf files into the container directory
COPY ./urw-din-regular.ttf /usr/local/share/fonts/FNZ/
