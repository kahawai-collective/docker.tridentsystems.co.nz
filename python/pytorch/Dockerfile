FROM docker.kahawai.net.nz/python/nz

COPY requirements.txt /etc/kahawai-jobserver/requirements.txt

RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir -r /etc/kahawai-jobserver/requirements.txt
