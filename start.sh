#!/bin/bash

docker volume ls | grep pgdata > /dev/null 2>&1
if [[ $? != 0 ]]; then
    docker volume create pgdata
fi

docker volume ls | grep pga4data > /dev/null 2>&1
if [[ $? != 0 ]]; then
    docker volume create pga4data
fi

docker network list |grep pgnetwork > /dev/null 2>&1
if [[ $? != 0 ]]; then
    docker network create --driver bridge pgnetwork
fi

cat << EOF > /tmp/pgadmin-env.list
PGADMIN_DEFAULT_EMAIL=jamie.maynard@me.com
PGADMIN_DEFAULT_PASSWORD=8lScP10eY1L3oeXbBM1E
PGADMIN_LISTEN_PORT=5050
EOF

docker run --rm --name postgres \
    --network pgnetwork \
    --hostname postgres \
    -e POSTGRES_PASSWORD=docker \
    -d -p 5432:5432 \
    --volume pgdata:/var/lib/postgresql/data \
    postgres

docker run --rm --name pgadmin4 \
    -d -p 5050:5050 \
    -v pga4data:/var/lib/pgadmin \
    --env-file /tmp/pgadmin-env.list \
    --hostname pgadmin4 \
    --network pgnetwork \
    dpage/pgadmin4 
