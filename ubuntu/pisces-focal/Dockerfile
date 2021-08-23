FROM docker.kahawai.net.nz/ubuntu/nz-focal

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y awscli s3cmd jq

COPY withdb /usr/local/bin/

COPY md2sql /usr/local/bin/
