FROM docker.kahawai.net.nz/ubuntu/gorbachev-base-jammy
MAINTAINER david@pisces.nz

COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r
RUN Rscript /etc/kahawai-jobserver/r_requirements.r

RUN mkdir -p -v /usr/local/lib/R/site-library/paua_sam
RUN cd /usr/local/lib/R/site-library/paua_sam && \
    wget https://github.com/kahawai-collective/PAUA-Stock-Assessment-Model/blob/main/ASSESSMENTS/QMA_def.R && \
    pwd && ls -la
