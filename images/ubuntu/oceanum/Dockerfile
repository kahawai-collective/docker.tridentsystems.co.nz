FROM docker.kahawai.net.nz/ubuntu/gorbachev-base-jammy
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget python3-pip python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN pip3 install --upgrade pip setuptools wheel
RUN pip install oceanum pyreadr rpy2

