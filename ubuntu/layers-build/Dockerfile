FROM docker.tridentsystems.co.nz/ubuntu/kahawai-build
MAINTAINER richard@dragonfly.co.nz

RUN apt-get update &&  \
    apt-get install postgis uuid -y && \
    apt-get install --no-install-recommends -y python-pip

RUN pip install --upgrade pip setuptools

RUN pip install PyDrive pyshp pngcanvas
