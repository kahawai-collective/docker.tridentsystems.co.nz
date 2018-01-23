FROM docker.tridentsystems.co.nz/ubuntu/texlive-r
MAINTAINER richard@dragonfly.co.nz

RUN apt-get update && apt-get install --no-install-recommends -y postgresql-client-9.5 git-core python-pygments jags libgdal-dev gdal-bin curl
RUN apt-get install --no-install-recommends -y libgdal1-dev libproj-dev \
    libudunits2-dev libcairo2-dev libxt-dev

COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r

RUN Rscript /etc/kahawai-jobserver/r_requirements.r

# TODO: something less fragile
RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub

RUN apt-get update && apt-get install -y software-properties-common
RUN apt-add-repository multiverse && apt-get update
RUN apt-get install -y msttcorefonts
# libraries necessary to run docker
# RUN apt-get update && apt-get install -y libapparmor1 libsystemd-journal0 libcgmanager0 libnih-dbus1 libnih1 libdbus-1-3 libgcrypt11


RUN apt-get install -y pandoc
# # Get pandoc from cabal
# RUN add-apt-repository -y ppa:hvr/ghc
# RUN apt-get update
# RUN apt-get install -y cabal-install-1.22 ghc-7.10.3
# ENV PATH=~/.cabal/bin:/opt/cabal/1.22/bin:/opt/ghc/7.10.3/bin:$PATH
# RUN cabal update
# RUN curl https://www.stackage.org/lts-5/cabal.config?global=true >> /root/.cabal/config
# RUN cabal install --global pandoc

COPY fonts/ /usr/local/share/fonts/

COPY dragonfly-latex-templates_1.13_all.deb /tmp/
RUN dpkg -i /tmp/dragonfly-latex-templates_1.13_all.deb
COPY trident-latex-templates_1.41_all.deb /tmp/
RUN dpkg -i /tmp/trident-latex-templates_1.41_all.deb
COPY mpi-latex-templates_1.19_all.deb /tmp/
RUN dpkg -i /tmp/mpi-latex-templates_1.19_all.deb
