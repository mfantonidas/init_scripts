#!/bin/sh

CFG_PATH=/tmp/test/init_scripts
CFG_FILE=$CFG_PATH/test.cfg
CHGDEV_FILE=$CFG_PATH/init_interface.sh
CHG_DEV="0"
DEL_BR=$CFG_PATH/del_br_mtk.sh
CFGDB="/tmp/test/db/conf.db"
BR_INIT_FILE="$CFG_PATH/build_init_br_mtk.sh"
CM_FILE="/tmp/test/cm/cm --pidfile --detach --log-file=/tmp/mnt/cm.log"
HTTPD="/etc/init.d/inetd"
NM_NS="NM"
MNG_NS="MNG"
DHCPD="/etc/init.d/isc-dhcp-server"
IP_CMD=/usr/bin/ip
NS_EXEC="$IP_CMD netns exec"

if [ "$CHG_DEV" = "1" ];then
	$CHGDEV_FILE
fi

$DEL_BR
sleep 1
$BR_INIT_FILE &
sleep 1

#cp /tmp/test/httpd/service /etc/
#cp /tmp/test/httpd/inetd.conf /etc/
#killall bftpd
#/userfs/bin/inetd -d &
#echo "inetd restart ok"
#$NS_EXEC $NM_NS $DHCPD start &
#sleep 4
#$NS_EXEC $NM_NS $HTTPD  restart &
#sleep 4
#$CM_FILE -v &
