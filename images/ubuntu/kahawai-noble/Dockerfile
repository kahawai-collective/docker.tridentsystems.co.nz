FROM docker.kahawai.net.nz/ubuntu/nz-noble

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y s3cmd \
    python-is-python3 python3-requests python3-requests-toolbelt \
    python3-yaml jq curl wget git-core dirmngr software-properties-common gpg-agent unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

COPY withdb /usr/local/bin/

COPY md2sql /usr/local/bin/
