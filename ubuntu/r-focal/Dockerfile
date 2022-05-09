FROM docker.kahawai.net.nz/ubuntu/pisces-focal

# Following approach from https://cloud.r-project.org/bin/linux/ubuntu/ as at 9 May 2022

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common dirmngr wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        r-base-dev \
        r-recommended \
        r-base \
        libpq-dev libgdal-dev libproj-dev libgeos-dev \
        curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository ppa:c2d4u.team/c2d4u4.0+
RUN apt-get update
