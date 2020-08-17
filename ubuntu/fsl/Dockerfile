# A Docker image for using the Fisheries Simulation Library (FSL)

FROM docker.pisces.net.nz/ubuntu/gorbachev-base

RUN git clone https://github.com/trident-systems/fsl.git && \
    cd fsl && \
    make requires
