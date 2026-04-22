FROM docker.kahawai.net.nz/ubuntu/kahawai-noble

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y \
    python3-pip postgresql-common gnupg

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
    gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg

RUN echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > \
    /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && apt-get install -y \
    postgresql-client-18 \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages --no-cache-dir "xlsx2csv==0.8.6"

RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub
