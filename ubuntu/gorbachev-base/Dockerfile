FROM docker.tridentsystems.co.nz/ubuntu/texlive-r
MAINTAINER richard@dragonfly.co.nz

RUN apt-get update && apt-get install --no-install-recommends -y postgresql-client-9.3 git-core pandoc python-pygments jags

COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r

RUN R --slave < /etc/kahawai-jobserver/r_requirements.r

# TODO: something less fragile
RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub

RUN apt-get install -y software-properties-common
RUN apt-add-repository multiverse && apt-get update
RUN apt-get install -y msttcorefonts

COPY fonts/ /usr/local/share/fonts/

COPY dragonfly-latex-templates_1.6_all.deb /tmp/ 
COPY trident-latex-templates_1.4_all.deb /tmp/ 
RUN dpkg -i /tmp/dragonfly-latex-templates_1.6_all.deb
RUN dpkg -i /tmp/trident-latex-templates_1.4_all.deb