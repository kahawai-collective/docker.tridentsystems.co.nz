FROM docker.kahawai.net.nz/ubuntu/r-bleedingedge

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Following https://unix.stackexchange.com/a/7653
RUN wget -q -P/tmp/ https://github.com$(wget -O- -q https://github.com/quarto-dev/quarto-cli/releases/latest | sed -ne 's/^.*"\([^"]*quarto[^"]*linux-amd64\.deb\)".*/\1/p')
RUN dpkg -i /tmp/quarto-*-linux-amd64.deb
RUN  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
