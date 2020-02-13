FROM docker.tridentsystems.co.nz/ubuntu/texlive-r
MAINTAINER richard@dragonfly.co.nz

RUN apt-get update && apt-get install --no-install-recommends -y postgresql-client git-core python-pygments jags gdal-bin curl
RUN apt-get install --no-install-recommends -y libudunits2-dev libcairo2-dev libxt-dev \
    libssl-dev libgmp3-dev

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

COPY fonts/ /usr/local/share/fonts/

COPY dragonfly-latex-templates_1.13_all.deb /tmp/
RUN dpkg -i /tmp/dragonfly-latex-templates_1.13_all.deb
COPY trident-latex-templates_1.6_all.deb /tmp/
RUN dpkg -i /tmp/trident-latex-templates_1.6_all.deb
COPY pisces-latex-templates_0.3_all.deb /tmp/
RUN dpkg -i /tmp/pisces-latex-templates_0.3_all.deb
COPY mpi-latex-templates_1.24_all.deb /tmp/
RUN dpkg -i /tmp/mpi-latex-templates_1.24_all.deb
