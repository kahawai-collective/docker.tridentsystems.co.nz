FROM docker.kahawai.net.nz/ubuntu/gorbachev-base-jammy
MAINTAINER david@pisces.nz

RUN apt-get update && \
    apt-get install -y --no-install-recommends gh \
                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY r_requirements.r /etc/kahawai-jobserver/r_requirements.r
RUN Rscript /etc/kahawai-jobserver/r_requirements.r

ENV PAUUSER=${PAUUSER}
ENV PAU=${PAU}

# TODO: ask Richard for help with this

# see https://cli.github.com/manual/gh_help_environment
# Q: where to set the GH username?
# Is this necessary since "GH_TOKEN" can be defined in the environment?
# RUN echo ${PAU} | gh auth login --with-token
# RUN export GH_TOKEN=${PAU} && gh auth status

RUN mkdir -p -v ~/.config/gh
COPY *.yml ~/.config/gh/
RUN cd ~/.config/gh && \
    sed -i "s/GHTOKEN/$PAU/" hosts.yml && \
    sed -i "s/GHUSER/$PAUUSER/" hosts.hml
RUN gh auth status

RUN mkdir -p -v /usr/local/lib/R/site-library/paua.sam

# see https://stackoverflow.com/questions/2466735/how-to-sparsely-checkout-only-one-single-file-from-a-git-repository/52270527/#52270527
# RUN cd /usr/local/lib/R/site-library/paua.sam && \
#     git clone --depth=1 --no-checkout --filter=blob:none https://github.com/kahawai-collective/PAUA-Stock-Assessment-Model.git gitcopy && \
#     cd gitcopy && \
#     git checkout main -- ASSESSMENTS/QMA_dev.R && \
#     cp ASSESSMENTS/QMA_dev.R ../ && \
#     cd .. && rm -r gitcopy && pwd && ls -la
