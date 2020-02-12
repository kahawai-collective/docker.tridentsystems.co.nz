FROM docker.tridentsystems.co.nz/ubuntu/nz

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y python-requests awscli s3cmd

COPY withdb /usr/local/bin/
