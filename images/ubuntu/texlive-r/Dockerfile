FROM docker.kahawai.net.nz/ubuntu/r

RUN apt-get update && \
    apt-get install -y --no-install-recommends texlive-full wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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

RUN apt-get update && \
    apt-get install -y --no-install-recommends biber && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && \
    apt-get install -y debhelper software-properties-common \
                        fakeroot build-essential lintian devscripts && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
