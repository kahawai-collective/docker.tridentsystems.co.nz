FROM docker.tridentsystems.co.nz/ubuntu/kahawai-build
MAINTAINER richard@dragonfly.co.nz

RUN apt-get update &&  \
    apt-get install postgis -y && \
    apt-get install --no-install-recommends -y python-pip

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
