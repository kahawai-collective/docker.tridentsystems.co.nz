FROM docker.kahawai.net.nz/ubuntu/texlive-r-focal
MAINTAINER richard@dragonfly.co.nz

RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client \
                                               git-core \
                                               python-pygments \
                                               jags \
                                               gdal-bin \
                                               libudunits2-dev \
                                               libcairo2-dev \
                                               libxt-dev \
                                               libv8-dev \
                                               libssl-dev \
                                               libgmp3-dev \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN apt-get update && \
    apt-get install -y --no-install-recommends r-cran-rstan \
                                               r-cran-tidyverse \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r
#RUN Rscript /etc/kahawai-jobserver/r_requirements.r


# TODO: something less fragile
RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub

# RUN apt-add-repository multiverse && apt-get update
# RUN apt-get install -y msttcorefonts
# RUN apt-get install -y pandoc

# COPY fonts/ /usr/local/share/fonts/

# COPY dragonfly-latex-templates_1.13_all.deb /tmp/
# RUN dpkg -i /tmp/dragonfly-latex-templates_1.13_all.deb
# COPY trident-latex-templates_1.6_all.deb /tmp/
# RUN dpkg -i /tmp/trident-latex-templates_1.6_all.deb
# COPY pisces-latex-templates_0.32_all.deb /tmp/
# RUN dpkg -i /tmp/pisces-latex-templates_0.32_all.deb
# COPY mpi-latex-templates_1.31_all.deb /tmp/
# RUN dpkg -i /tmp/mpi-latex-templates_1.31_all.deb
