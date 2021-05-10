#!/bin/bash
if [[ -z $PSQL_PORT ]]; then
    PSQL_PORT=5432
fi

if [[ $(uname) == "Linux" ]]; then
    if groups $(whoami) |grep docker > /dev/null 2>&1; then
        DOCKER_CMD="docker"
    else
        DOCKER_CMD="sudo docker"
        sudowarn
    fi
else
    DOCKER_CMD="docker"
fi

$DOCKER_CMD run -it --rm --network pgnetwork postgres psql -h postgres -p $PSQL_PORT -U postgres
