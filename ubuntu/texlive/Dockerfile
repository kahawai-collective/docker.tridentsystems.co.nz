FROM docker.tridentsystems.co.nz/ubuntu/nz

RUN apt-get update && \
    apt-get install -y --no-install-recommends texlive-full wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget https://launchpad.net/ubuntu/+source/biber/2.4-1ubuntu1.16.04.1/+build/10029926/+files/biber_2.4-1ubuntu1.16.04.1_all.deb && \
    dpkg -i biber_2.4-1ubuntu1.16.04.1_all.deb
