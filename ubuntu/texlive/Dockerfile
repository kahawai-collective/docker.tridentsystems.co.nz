FROM docker.tridentsystems.co.nz/ubuntu/nz

RUN apt-get update && \
    apt-get install -y --no-install-recommends texlive-full wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# biber package is broken in 16.04
# TODO Remove the following when xenial-updates has a version of biber
# compatible with texlive-full

RUN apt-get update && \
    apt-get install -y --no-install-recommends libautovivification-perl \
    libclass-accessor-perl libdata-compare-perl libdata-dump-perl libdata-uniqid-perl \
    libdate-simple-perl libencode-eucjpms-perl libencode-hanextra-perl \
    libencode-jis2k-perl libfile-slurp-unicode-perl \
    libipc-run3-perl \
    liblwp-protocol-https-perl \
    liblist-allutils-perl \
    liblist-moreutils-perl \
    liblog-log4perl-perl \
    libreadonly-perl \
    libregexp-common-perl \
    libtext-bibtex-perl \
    libtext-roman-perl \
    libunicode-collate-perl \
    libunicode-linebreak-perl \
    libwww-perl \
    libxml-libxml-simple-perl \
    libxml-libxslt-perl \
    libxml-writer-perl \
    libbusiness-isbn-perl \
    libbusiness-ismn-perl \
    libbusiness-issn-perl \
    liburi-perl \
    && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget https://launchpad.net/ubuntu/+source/biber/2.4-1ubuntu1.16.04.1/+build/10029926/+files/biber_2.4-1ubuntu1.16.04.1_all.deb && \
    dpkg -i biber_2.4-1ubuntu1.16.04.1_all.deb
