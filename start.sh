#!/bin/bash

# Define colors and styles
normal="\033[0m"
bold="\033[1m"
green="\e[32m"
red="\e[31m"
yellow="\e[93m"

# Define Icons (if in doubt try nerd font... then emoji.. finally nothing)
if [[ "$NERD_FONT" == 'true' ]]; then
  warn_icon="\uf071 "
  docker_icon="\uf308 "
  whale_icon="🐋"
elif [[ "$EMOJI" == 'false' ]]; then
  warn_icon="!"
  whale_icon=""
  docker_icon=""
else
  warn_icon="⚠️"
  whale_icon="🐋"
  docker_icon="🐳"
fi

sudowarn() {
    echo -e "$red╒═════════════════════════════════════════════════════════╕$normal"
    echo -e "$red│$normal $yellow$warn_icon $normal  WARNING                                             $red│$normal"
    echo -e "$red├─────────────────────────────────────────────────────────┤$normal"
    echo -e "$red│$normal You're not part of the docker group so you'll need      $red│$normal"
    echo -e "$red│$normal sudo access in order to run this script.  If you don't  $red│$normal"
    echo -e "$red│$normal have sudo access please ask an admin to add you to the  $red│$normal"
    echo -e "$red│$normal the docker group.                                       $red│$normal"
    echo -e "$red╘═════════════════════════════════════════════════════════╛$normal\n"
}

if [ -z $PSQL_PASSWORD ]; then
    PSQL_PASSWORD=docker
    PSQLPASS='default'
else
    PSQLPASS='current'
fi

if [ -z $PSQL_PORT ]; then
    PSQL_PORT=5432
    PSQLPO='default'
else
    PSQLPO='current'
fi

if [ -z $PGADMIN_PORT ]; then
    PGADMIN_PORT=5050
    PGAPORT='default'
else
    PGAPORT='current'
fi

if [ -z $PGADMIN_USER ]; then
    PGADMIN_USER=test@test.com
    PGAUSER='default'
else
    PGAUSER='current'
fi

if [ -z $PGADMIN_PASSWORD ]; then
    PGADMIN_PASSWORD=8lScP10eY1L3oeXbBM1E
    PGAPASS='default'
else
    PGAPASS='current'
fi

TEST=false

usage() {
    echo -e "Usage:"
    echo -e "  --psql-password     Sets the PostgreSQL password"
    echo -e "                      (The $PSQLPASS is '$PSQL_PASSWORD')\n"
    echo -e "  --psql-port         Sets the PostgreSQL port"
    echo -e "                      (The $PSQLPO is '$PSQL_PORT')\n"
    echo -e "  --pgadmin-port      Sets the port for PGAdmin 4"
    echo -e "                      (The $PGAPORT is '$PGADMIN_PORT')\n"
    echo -e "  --pgadmin-user      Sets the default login user for PGAdmin 4"
    echo -e "                      (The $PGAUSER is '$PGADMIN_USER')\n"
    echo -e "  --pgadmin-password  Sets the password for the default login for PGAdmin 4"
    echo -e "                      (The $PGAPASS is '$PGADMIN_PASSWORD')\n"
    echo -e "  -h  --help          Shows this usage message"
    echo -e "  -t   --test         Shows hows docker will be configrued but won't run docker"
}

showtest() {
    echo -e "Docker will be configured as follows:"
    echo -e "   PSQL_PASSWORD    = $PSQL_PASSWORD"
    echo -e "   PSQL_PORT        = $PSQL_PORT"
    echo -e "   PGADMIN_PORT     = $PGADMIN_PORT"
    echo -e "   PGADMIN_USER     = $PGADMIN_USER"
    echo -e "   PGADMIN_PASSWORD = $PGADMIN_PASSWORD"
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
        -t | --test )           TEST=true
                                ;;
        --show-warn )           sudowarn;
                                exit
                                ;;
        * )                     echo -e "Unknown option $1...\n"
                                usage
                                exit 1
    esac
    shift
done     

if groups $(whoami) |grep docker > /dev/null 2>&1; then
    DOCKER_CMD="docker"
else
    DOCKER_CMD="sudo docker"
    showwarn
fi

if [ $TEST == "true" ]; then
    showtest
    exit
fi

docker volume ls | grep pgdata > /dev/null 2>&1
if [[ $? != 0 ]]; then
    docker volume create pgdata > /dev/null 2>&1
fi

docker volume ls | grep pga4data > /dev/null 2>&1
if [[ $? != 0 ]]; then
    docker volume create pga4data > /dev/null 2>&1
fi

docker network list |grep pgnetwork > /dev/null 2>&1
if [[ $? != 0 ]]; then
    docker network create --driver bridge pgnetwork > /dev/null 2>&1
fi

docker ps -f name=postgres |grep postgres > /dev/null 2>&1
if [ $? != 0 ]; then
    echo -e " $whale_icon Starting PostgreSQL..."
    $DOCKER_CMD run --rm --name postgres \
        --network pgnetwork \
        --hostname postgres \
        -e POSTGRES_PASSWORD=$PSQL_PASSWORD \
        -d -p $PSQL_PORT:5432 \
        --volume pgdata:/var/lib/postgresql/data \
        postgres 1> /dev/null
else
    echo -e " $warn_icon  Docker is already running PostgreSQL"
fi

docker ps -f name=pgadmin4 |grep pgadmin4 > /dev/null 2>&1
if [ $? != 0 ]; then
    echo -e " $whale_icon Starting PGAdmin 4..."
    cat << EOF > /tmp/.pgadmin-env.list
PGADMIN_DEFAULT_EMAIL=$PGADMIN_USER
PGADMIN_DEFAULT_PASSWORD=$PGADMIN_PASSWORD
PGADMIN_LISTEN_PORT=$PGADMIN_PORT
EOF
    
    $DOCKER_CMD run --rm --name pgadmin4 \
        -d -p $PGADMIN_PORT:$PGADMIN_PORT \
        -v pga4data:/var/lib/pgadmin \
        --env-file /tmp/.pgadmin-env.list \
        --hostname pgadmin4 \
        --network pgnetwork \
        dpage/pgadmin4 1> /dev/null
    
    rm /tmp/.pgadmin-env.list
else
    echo -e " $warn_icon  Docker is already running PG Admin 4"
fi

echo -e " $docker_icon PostgreSQL and PGAdmin 4 are now running in Docker!"