FROM docker.kahawai.net.nz/python/nz

RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client \
                                               git-core \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY requirements.txt /etc/kahawai-jobserver/requirements.txt

#RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir -r /etc/kahawai-jobserver/requirements.txt

COPY withdb /usr/local/bin/

