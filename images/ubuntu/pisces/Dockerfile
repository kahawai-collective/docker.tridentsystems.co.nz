FROM docker.kahawai.net.nz/ubuntu/nz

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y python-requests awscli s3cmd \
    python-requests-toolbelt jq python3-yaml

COPY withdb /usr/local/bin/

COPY md2sql /usr/local/bin/
