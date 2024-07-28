FROM docker.kahawai.net.nz/ubuntu/gorbachev-base-bleedingedge
MAINTAINER philipp@dragonfly.co.nz

COPY r_requirements.r /r_requirements.r

RUN apt update && apt install -y libv8-dev
RUN Rscript /r_requirements.r