#!/bin/bash

if [ -z $PSQL_PASSWORD ]; then
    PSQL_PASSWORD=docker
fi
if [ -z $PSQL_PORT ]; then
    PSQL_PORT=5432
fi
if [ -z $PGADMIN_PORT ]; then
    PGADMIN_PORT=5050
fi
if [ -z $PGADMIN_USER ]; then
    PGADMIN_USER=test@test.com
fi
if [ -z $PGADMIN_PASSWORD ]; then
    PGADMIN_PASSWORD=8lScP10eY1L3oeXbBM1E
fi

if groups $(whoami) |grep docker > /dev/null 2>&1; then
    DOCKER_CMD="docker"
else
    DOCKER_CMD="sudo docker"
fi

usage() {
    echo -e "Usage:"
    echo -e "  --psql-password     Sets the PostgreSQL password"
    echo -e "                      (The default is 'docker')\n"
    echo -e "  --psql-port         Sets the PostgreSQL port"
    echo -e "                      (The default is '5432')\n"
    echo -e "  --pgadmin-port      Sets the port for PGAdmin 4"
    echo -e "                      (The default is '5050')\n"
    echo -e "  --pgadmin-user      Sets the default login user for PGAdmin 4"
    echo -e "                      (The default is 'test@test.test')\n"
    echo -e "  --pgadmin-password  Sets the password for the default login for PGAdmin 4"
    echo -e "                      (The default is '8lScP10eY1L3oeXbBM1E')\n"
}

while [ "$1" != "" ]; do                                                   
    case $1 in                                                             
        --psql-password )       shift
                                PSQL_PASSWORD=$1
                                ;;                                         
        --psql-port )           shift
                                PSQL_PORT=$1                            
                                ;;
        --pgadmin-port )        shift
                                PGADMIN_PORT=$1
                                ;;
        --pgadmin-user )        shift
                                PGADMIN_USER=$1
                                ;;
        --pgadmin-password )    shift
                                PGADMIN_PASSWORD=$1
                                ;;
        -h | --help )           usage                                   
                                exit                                    
                                ;;                                      
        * )                     echo -e "Unknown option...\n"
                                usage                                   
                                exit 1                                  
    esac                                                                
    shift                                                               
done       

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

cat << EOF > /tmp/.pgadmin-env.list
PGADMIN_DEFAULT_EMAIL=$PGADMIN_USER
PGADMIN_DEFAULT_PASSWORD=$PGADMIN_PASSWORD
PGADMIN_LISTEN_PORT=$PGADMIN_PORT
EOF

$DOCKER_CMD run --rm --name postgres \
    --network pgnetwork \
    --hostname postgres \
    -e POSTGRES_PASSWORD=$PSQL_PASSWORD \
    -d -p $PSQL_PORT:5432 \
    --volume pgdata:/var/lib/postgresql/data \
    postgres 1> /dev/null

$DOCKER_CMD run --rm --name pgadmin4 \
    -d -p $PGADMIN_PORT:$PGADMIN_PORT \
    -v pga4data:/var/lib/pgadmin \
    --env-file /tmp/.pgadmin-env.list \
    --hostname pgadmin4 \
    --network pgnetwork \
    dpage/pgadmin4 1> /dev/null

