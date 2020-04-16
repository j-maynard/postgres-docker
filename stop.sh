#!/bin/bash

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

docker stop postgres pgadmin4 1> /dev/null

if [ REMOVE_VOLS == 'true' ]; then
    docker volume rm pga4data > /dev/null 2>&1
    docker volume rm pgdata > /dev/null 2>&1
fi

if [ REMOVE_NET == 'true' ]; then
    docker network rm pgnetwork > /dev/null 2>&1
fi
