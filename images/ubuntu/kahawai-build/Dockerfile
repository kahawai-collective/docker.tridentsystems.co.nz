FROM docker.kahawai.net.nz/ubuntu/kahawai-noble

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y \
    postgresql-client s3cmd python3-psycopg2 ca-certificates \
    python3-pip

RUN pip3 install --break-system-packages --no-cache-dir "xlsx2csv==0.8.6"

RUN groupadd -g 1003 deployhub && useradd -m -g deployhub -u 1003 deployhub
