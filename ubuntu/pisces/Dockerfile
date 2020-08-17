FROM docker.pisces.net.nz/ubuntu/nz

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y python-requests awscli s3cmd \
    python-requests-toolbelt

COPY withdb /usr/local/bin/
