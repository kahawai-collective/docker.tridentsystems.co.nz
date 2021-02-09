FROM docker.pisces.net.nz/ubuntu/nz

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y python-requests awscli s3cmd \
    python-requests-toolbelt jq

COPY withdb /usr/local/bin/
COPY md2sql /usr/local/bin/
RUN chmod 755 /usr/local/bin/md2sql
