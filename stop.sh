#!/bin/bash

# Define colors and styles
normal="\033[0m"
bold="\033[1m"
green="\e[32m"
red="\e[31m"
yellow="\e[93m"

# Define Icons (if in doubt try nerd font... then emoji.. finally nothing)
if [[ "$NERD_FONT" == 'true' ]]; then
  stop_icon="\uf46e"
  trash_icon="\uf1f8"
  knet_icon="\uf700"
  dnet_icon="\uf701"
  done_icon="\uf634"
  hd_icon="\uf7c9"
elif [[ "$EMOJI" == 'false' ]]; then
  trash_icon=''
  stop_icon=''
  net_icon=''
  done_icon=''
  hd_icon=''
else
  hd_icon="💾"
  trash_icon="🗑️"
  stop_icon="🛑"
  knet_icon="🔌"
  dnet_icon="🔌"
  done_icon="✔️"
fi

# Source from config file
SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
echo "Config file is = $SCRIPTPATH/.config"
if [ -f "$SCRIPTPATH/.config" ]; then
    echo -e "$green $file_icon  Loading config data from file $SCRIPTPATH/.config... $normal"
    source .config
fi

if [ -z $PGCONTAINER_NAME ]; then
    PGCONTAINER_NAME=postgres
fi

if [ -z $REMOVE_VOLS ]; then
    REMOVE_VOLS=false
fi

if [ -z $REMOVE_NET ]; then
    REMOVE_NET=false
fi

usage()
{
    echo "Usage:"
    echo "  -v    --remove-vols   Removes the docker volumes and their data"
    echo "                        The default is to preserve the data"
    echo "  -n    --remove-net    Removes the pgnetwork created by the start script"
    echo "                        The default is to keep the network"
    echo "  -h    --help          Shows this message"
}

while [ "$1" != "" ]; do
    case $1 in
        -v | --remove-vols )    REMOVE_VOLS=true
                                ;;
        -n | --remove_net )     REMOVE_NET=true
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

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


$DOCKER_CMD ps -f name=pgadmin4 |grep pgadmin4 > /dev/null 2>&1
if [ $? == 0 ]; then
    echo -e " $stop_icon  Stopping PGAdmin 4..."
    $DOCKER_CMD stop pgadmin4 1> /dev/null
fi

$DOCKER_CMD ps -f name=$PGCONTAINER_NAME |grep $PGCONTAINER_NAME > /dev/null 2>&1
if [ $? == 0 ]; then
    echo -e " $stop_icon  Stopping PostreSQL..."
    $DOCKER_CMD stop $PGCONTAINER_NAME 1> /dev/null
fi

if [ $REMOVE_VOLS == 'true' ]; then
    $DOCKER_CMD volume ls -f name=pga4data |grep pga4data > /dev/null 2>&1
    if [ $? == 0 ]; then
        echo -e " $trash_icon $red Removing PGAdmin data... $normal"
        $DOCKER_CMD volume rm pga4data > /dev/null 2>&1
    fi
    $DOCKER_CMD volume ls -f name=pgdata |grep pgdata> /dev/null 2>&1
    if [ $? == 0 ]; then
        echo -e " $trash_icon $red Removing PostgreSQL data... $normal"
        $DOCKER_CMD volume rm pgdata > /dev/null 2>&1
    fi
else
    count=0
    $DOCKER_CMD volume ls -f name=pga4data |grep pga4data > /dev/null 2>&1
    count=$count+$?
    $DOCKER_CMD volume ls -f name=pgdata |grep pgdata> /dev/null 2>&1
    count=$count+$?
    if [ $count == 0 ]; then
        echo -e " $hd_icon  Persisting Data by keeping docker volumes."
    fi
fi

if [ $REMOVE_NET == 'true' ]; then
    $DOCKER_CMD network ls -f name=pgnetwork |grep pgnetwork > /dev/null 2>&1
    if [ $? == 0 ]; then
        echo -e " $dnet_icon $red Removing PGNetwork $normal"
        $DOCKER_CMD network rm pgnetwork > /dev/null 2>&1
    fi
else
    $DOCKER_CMD network ls -f name=pgnetwork |grep pgnetwork > /dev/null 2>&1
    if [ $? == 0 ]; then
        echo -e " $knet_icon  Keeping PGNetwork active."
    fi
fi
echo -e " $done_icon  All done."