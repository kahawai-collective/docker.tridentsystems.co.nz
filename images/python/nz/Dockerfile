FROM python:3.13.7

# Set timezone & locale

RUN apt-get update && apt-get install -y tzdata locales && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "Pacific/Auckland" > /etc/timezone
RUN ln -fs /usr/share/zoneinfo/Pacific/Auckland /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

RUN echo "en_NZ.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_NZ.UTF-8

RUN dpkg-reconfigure locales

ENV LC_ALL en_NZ.UTF-8
ENV LANG en_NZ.UTF-8
ENV LANGUAGE en_NZ:en

ENV TZ="Pacific/Auckland"
