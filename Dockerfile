FROM steamcmd/steamcmd

LABEL org.opencontainers.image.authors="bryangob@ymail.com"
LABEL org.opencontainers.image.source="https://github.com/BryanGoble/Puck-Dedicated-Server-SteamCMD"

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y install --no-install-recommends ca-certificates locales steamcmd jq && \
    rm -rf /var/lib/apt/lists/*

ENV DATA_DIR="/serverdata"
ENV STEAMCMD_DIR="${DATA_DIR}/steamcmd"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV CONFIG="${SERVER_DIR}/server_configuration.json"
ENV GAME_NAME="template" \
    GAME_PASSWRD="" \
    GAME_PORT=7777 \
    PING_PORT=7778 \
    MAX_PLAYERS=10 \
    VOIP=false \
    IS_PUBLIC=true \
    ADMIN_ID="" \
    START_PAUSE=false \
    ALLOW_VOTE=true \
    GAME_ID="template" \
    VALIDATE="" \
    TARGET_FR=120 \
    SERVER_TR=100 \
    CLIENT_TR=200 \
    RELOAD_BAN_ID=false \
    USE_PUCK_BAN_ID=true \
    PRINT_METRIC=true \
    KICK_TO=300 \
    SLEEP_TO=60 \
    JOIN_MM_DELAY=10 \
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
