#!/bin/bash
set -e

echo "---Preparing Puck Dedicated Server---"

echo "---Update SteamCMD---"
if [ "${USERNAME}" == "" ]; then
    steamcmd \
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
        steamcmd \
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

echo "---Configuring Puck Server---"
echo "---Injecting Variable Values---"

# Only replace if variable is set
[ -n "$GAME_PORT" ]      && sed -i "s|\"port\": 7777|\"port\": ${GAME_PORT}|g" "$CONFIG"
[ -n "$PING_PORT" ]      && sed -i "s|\"pingPort\": 7778|\"pingPort\": ${PING_PORT}|g" "$CONFIG"
[ -n "$GAME_NAME" ]      && sed -i "s|\"name\": \"MY PUCK SERVER\"|\"name\": \"${GAME_NAME}\"|g" "$CONFIG"
[ -n "$MAX_PLAYERS" ]    && sed -i "s|\"maxPlayers\": 10|\"maxPlayers\": ${MAX_PLAYERS}|g" "$CONFIG"
[ -n "$GAME_PASSWRD" ]   && sed -i "s|\"password\": \"\"|\"password\": \"${GAME_PASSWRD}\"|g" "$CONFIG"
[ -n "$VOIP" ]           && sed -i "s|\"voip\": false|\"voip\": ${VOIP}|g" "$CONFIG"
[ -n "$IS_PUBLIC" ]      && sed -i "s|\"isPublic\": true|\"isPublic\": ${IS_PUBLIC}|g" "$CONFIG"
IDS_ARRAY=$(echo "$ADMIN_ID" | awk -F, '{for(i=1;i<=NF;i++){printf "\"%s\"%s",$i,(i==NF?"":",")}}')
jq --argjson ids "[$IDS_ARRAY]" '.adminSteamIds = $ids' ${CONFIG} > ${CONFIG}.new && mv ${CONFIG}.new ${CONFIG}
[ -n "$RELOAD_BAN_ID" ]  && sed -i "s|\"reloadBannedSteamIds\": false|\"reloadBannedSteamIds\": ${RELOAD_BAN_ID}|g" "$CONFIG"
[ -n "$USE_PUCK_BAN_ID" ]&& sed -i "s|\"usePuckBannedSteamIds\": true|\"usePuckBannedSteamIds\": ${USE_PUCK_BAN_ID}|g" "$CONFIG"
[ -n "$PRINT_METRIC" ]   && sed -i "s|\"printMetrics\": true|\"printMetrics\": ${PRINT_METRIC}|g" "$CONFIG"
[ -n "$KICK_TO" ]        && sed -i "s|\"kickTimeout\": 300|\"kickTimeout\": ${KICK_TO}|g" "$CONFIG"
[ -n "$SLEEP_TO" ]       && sed -i "s|\"sleepTimeout\": 60|\"sleepTimeout\": ${SLEEP_TO}|g" "$CONFIG"
[ -n "$JOIN_MM_DELAY" ]  && sed -i "s|\"joinMidMatchDelay\": 10|\"joinMidMatchDelay\": ${JOIN_MM_DELAY}|g" "$CONFIG"
[ -n "$TARGET_FR" ]      && sed -i "s|\"targetFrameRate\": 120|\"targetFrameRate\": ${TARGET_FR}|g" "$CONFIG"
[ -n "$SERVER_TR" ]      && sed -i "s|\"serverTickRate\": 100|\"serverTickRate\": ${SERVER_TR}|g" "$CONFIG"
[ -n "$CLIENT_TR" ]      && sed -i "s|\"clientTickRate\": 200|\"clientTickRate\": ${CLIENT_TR}|g" "$CONFIG"
[ -n "$START_PAUSE" ]    && sed -i "s|\"startPaused\": false|\"startPaused\": ${START_PAUSE}|g" "$CONFIG"
[ -n "$ALLOW_VOTE" ]     && sed -i "s|\"allowVoting\": true|\"allowVoting\": ${ALLOW_VOTE}|g" "$CONFIG"

echo "---Config injection complete---"

chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}
if [ ! -f 'Puck.x86_64' ]; then
    echo "---Something went wrong, can't find the executable, putting container into sleep mode!---"
    sleep infinity
else
    ./Puck.x86_64
fi