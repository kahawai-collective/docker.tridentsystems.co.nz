FROM docker.kahawai.net.nz/ubuntu/gorbachev-base
MAINTAINER philipp@dragonfly.co.nz

COPY r_requirements.r /r_requirements.r

RUN apt update && apt install -y libv8-dev
RUN Rscript /r_requirements.r
RUN rm -rf /usr/local/lib/R/site-library/StanHeaders/include/tbb
