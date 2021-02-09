FROM docker.kahawai.net.nz/ubuntu/kahawai-build
MAINTAINER richard@dragonfly.co.nz

RUN apt-get update &&  \
    apt-get install postgis uuid gdal-bin -y && \
    apt-get install --no-install-recommends -y python-pip

RUN pip install --upgrade pip setuptools

RUN pip install PyDrive pyshp pngcanvas
