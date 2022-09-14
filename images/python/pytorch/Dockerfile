FROM docker.kahawai.net.nz/python/nz

COPY requirements.txt /etc/kahawai-jobserver/requirements.txt

#RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir -r /etc/kahawai-jobserver/requirements.txt

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils \
                                               python3-opencv \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
