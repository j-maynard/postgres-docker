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

echo -e " $stop_icon  Stopping PostreSQL and PGAdmin..."
docker stop postgres pgadmin4 1> /dev/null

if [ $REMOVE_VOLS == 'true' ]; then
    echo -e " $trash_icon $red Removing PostgreSQL and PGAdmin data $normal"
    docker volume rm pga4data > /dev/null 2>&1
    docker volume rm pgdata > /dev/null 2>&1
else
    echo -e " $hd_icon  Persisting Data by keeping docker volumes."
fi

if [ $REMOVE_NET == 'true' ]; then
    echo -e " $dnet_icon $red Removing PGNetwork $normal"
    docker network rm pgnetwork > /dev/null 2>&1
else
    echo -e " $knet_icon  Keeping PGNetwork active."
fi
echo -e " $done_icon  All done."