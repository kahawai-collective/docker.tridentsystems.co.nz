FROM docker.tridentsystems.co.nz/ubuntu/nz
MAINTAINER finlay@dragonfly.co.nz

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y \
                postgresql-client-9.5 \
                git-core python-psycopg2

# TODO: something less fragile
RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub

