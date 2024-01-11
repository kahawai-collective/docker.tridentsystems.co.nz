FROM docker.kahawai.net.nz/ubuntu/gorbachev-base-jammy
MAINTAINER david@pisces.nz

COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r
RUN Rscript /etc/kahawai-jobserver/r_requirements.r

ARG PAU
ENV PAU=$PAU
RUN mkdir -p -v /usr/local/lib/R/site-library/paua.sam
RUN cd /usr/local/lib/R/site-library/paua.sam && \
    wget -q0- --user=Philipp-Neubauer --password=${PAU} https://raw.githubusercontent.com/kahawai-collective/PAUA-Stock-Assessment-Model/main/ASSESSMENTS/QMA_def.R && \
    pwd && ls -la
