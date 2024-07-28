FROM docker.kahawai.net.nz/python/nz

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y 
    awscli \
    s3cmd \
    python-is-python3 \
    python3-requests \
    python3-requests-toolbelt \
    python3-yaml \
    jq \
    curl \
    wget \
    git-core \
    dirmngr \
    software-properties-common \
    gpg-agent \
    postgresql-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY requirements.txt /etc/kahawai-jobserver/requirements.txt

#RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir -r /etc/kahawai-jobserver/requirements.txt

COPY withdb /usr/local/bin/.
RUN chmod a+x /usr/local/bin/withdb
