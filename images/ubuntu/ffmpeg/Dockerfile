FROM docker.kahawai.net.nz/ubuntu/pisces-focal
MAINTAINER david@pisces.nz

RUN apt-get update && \
    apt-get install --no-install-recommends -y postgresql-client \
                                               git-core \
                                               curl \
                                               ffmpeg \
                                               libavcodec-extra \
                                               zip \
                                               unzip \
                                               imagemagick  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


COPY photoncrypt /usr/local/bin/
RUN chmod a+x /usr/local/bin/photoncrypt

# TODO: something less fragile
RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub
