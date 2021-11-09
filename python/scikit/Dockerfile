FROM python:3.10

# Set timezone & locale

#ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y tzdata locales && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "Pacific/Auckland" > /etc/timezone
RUN ln -fs /usr/share/zoneinfo/Pacific/Auckland /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

RUN locale-gen en_NZ.UTF-8
RUN dpkg-reconfigure locales

ENV LANG en_NZ.UTF-8
ENV LANGUAGE en_NZ:en

COPY requirements.txt /etc/kahawai-jobserver/requirements.txt

RUN pip3 install --no-cache-dir -r /etc/kahawai-jobserver/requirements.txt
