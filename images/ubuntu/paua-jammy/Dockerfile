FROM docker.kahawai.net.nz/ubuntu/gorbachev-base-jammy
MAINTAINER david@pisces.nz

RUN apt-get update && \
    apt-get install -y --no-install-recommends gh \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r
RUN Rscript /etc/kahawai-jobserver/r_requirements.r

ARG PAUUSER
ARG PAU

ENV GH_TOKEN=$PAU
RUN gh auth login --with-token < echo $GH_TOKEN

RUN mkdir -p -v /usr/local/lib/R/site-library/paua.sam

# see https://stackoverflow.com/revisions/52270527/6
# RUN cd /usr/local/lib/R/site-library/paua.sam && \
#     git clone --depth=1 --no-checkout --filter=blob:none https://github.com/kahawai-collective/PAUA-Stock-Assessment-Model.git gitcopy && \
#     cd gitcopy && \
#     git checkout main -- ASSESSMENTS/QMA_dev.R && \
#     cp ASSESSMENTS/QMA_dev.R ../ && \
#     cd .. && rm -r gitcopy && pwd && ls -la
