#!/bin/bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${SERVER_DIR}/linux64
export TERM=xterm

echo "---Preparing Banana Shooter Dedicated Server---"
if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
    echo "SteamCMD not found!"
    wget -q --show-progress --progress=bar:force:noscroll -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz
    rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
fi

echo "---Update SteamCMD---"
if [ "${USERNAME}" == "" ]; then
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login anonymous \
    +quit
else
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login ${USERNAME} ${PASSWRD} \
    +quit
fi

echo "---Update Server---"
if [ "${USERNAME}" == "" ]; then
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
	+@sSteamCmdForcePlatformType linux \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
	+@sSteamCmdForcePlatformType linux \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} \
        +quit
    fi
else
    if [ "${VALIDATE}" == "true" ]; then
        echo "---Validating installation---"
	${STEAMCMD_DIR}/steamcmd.sh \
	+@sSteamCmdForcePlatformType linux \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
	+@sSteamCmdForcePlatformType linux \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} \
        +quit
    fi
fi

echo "---Prepare Server---"
if [ ! -f ${DATA_DIR}/.steam/sdk64/steamclient.so ]; then
	if [ ! -d ${DATA_DIR}/.steam ]; then
    	mkdir ${DATA_DIR}/.steam
    fi
	if [ ! -d ${DATA_DIR}/.steam/sdk64 ]; then
    	mkdir ${DATA_DIR}/.steam/sdk64
    fi
    cp -R ${STEAMCMD_DIR}/linux64/* ${DATA_DIR}/.steam/sdk64/
    cp -R ${STEAMCMD_DIR}/linux64/* ${SERVER_DIR}
fi

if [ ! -f ${DATA_DIR}/.steam/sdk32/steamclient.so ]; then
	if [ ! -d ${DATA_DIR}/.steam ]; then
    	mkdir ${DATA_DIR}/.steam
    fi
	if [ ! -d ${DATA_DIR}/.steam/sdk32 ]; then
    	mkdir ${DATA_DIR}/.steam/sdk32
    fi
    cp -R ${STEAMCMD_DIR}/linux32/* ${DATA_DIR}/.steam/sdk32/
fi

chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}
if [ ! -f ./BSDS.x86_64 ]; then
  echo "---Something went wrong, can't find the executable, putting container into sleep mode!---"
  sleep infinity
else
  ./BSDS.x86_64 -batchmode -nographics +Server ${GAME_NAME} +maxplayercount ${MAX_PLAYERS} +port ${GAME_PORT} "$@"
fi