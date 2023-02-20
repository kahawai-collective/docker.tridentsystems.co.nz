FROM docker.kahawai.net.nz/ubuntu/pisces-jammy
MAINTAINER finlay@dragonfly.co.nz

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y \
    postgresql-client awscli s3cmd unzip git-core python-psycopg2 ca-certificates \
    python3-unicodecsv xlsx2csv

# TODO: something less fragile
RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub
