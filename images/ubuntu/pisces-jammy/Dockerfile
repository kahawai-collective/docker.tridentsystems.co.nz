FROM docker.kahawai.net.nz/ubuntu/nz-jammy

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y awscli s3cmd \
    python-is-python3 python3-requests python3-requests-toolbelt \
    python3-yaml jq curl wget git-core dirmngr software-properties-common gpg-agent && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY withdb /usr/local/bin/

COPY md2sql /usr/local/bin/
