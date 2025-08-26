#FROM steamcmd/steamcmd:debian-bullseye
#FROM ich777/debian-baseimage:bullseye_amd64
FROM ich777/debian-baseimage

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-steamcmd-server"

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y install --no-install-recommends lib32z1 libbz2-1.0:i386 lib32gcc-s1 lib32stdc++6 libcurl4-gnutls-dev:i386 zlib1g:i386 libxrandr2:i386 libxi6:i386 lib32gcc-s1 libcurl4 libfontconfig1 libpangocairo-1.0-0 libnss3 libxi6 libxcursor1 libxss1 libxcomposite1 libasound2 libxdamage1 libxtst6 libatk1.0-0 libxrandr2 iputils-ping libcurl3-gnutls xterm wget tar file && \
    rm -rf /var/lib/apt/lists/*

ENV DATA_DIR="/serverdata"
ENV STEAMCMD_DIR="${DATA_DIR}/steamcmd"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV GAME_ID="template" \
    GAME_NAME="template" \
    GAME_PARAMS="template" \
    GAME_PORT=27015 \
    MAX_PLAYERS=10 \
    VALIDATE="" \
    UMASK=000 \
    UID=99 \
    GID=100 \
    USERNAME="" \
    PASSWRD="" \
    USER="steam" \
    DATA_PERM=770

RUN mkdir $DATA_DIR && \
    mkdir $STEAMCMD_DIR && \
    mkdir $SERVER_DIR && \
    useradd -d $DATA_DIR -s /bin/bash $USER && \
    chown -R $USER $DATA_DIR && \
    ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]
