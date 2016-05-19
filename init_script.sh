#!/bin/bash

CFG_PATH=.
CFG_FILE=$CFG_PATH/test.cfg
CHGDEV_FILE=$CFG_PATH/init_interface.sh
export CFG_PATH
export CFG_FILE
CHG_DEV="0"
export CHG_DEV
WORK_PATH=/usr/local
CFGDB=$WORK_PATH/etc/conf.db
BR_INIT_FILE=./build_init_br.sh
CM_FILE=
HTTPD=
NM_NS=NM-internal
MNG_NS=MNG-namespace
NS_EXEC="ip netns exec"
DHCPD="/etc/init.d/isc-dhcp-server"
export NM_NS
export MNG_NS
export NS_EXEC

if [ "$CHG_DEV" = "1" ];then
	$CHGDEV_FILE
fi

if test -e $CFGDB
then
	echo "conf.db exist"
else
	$BR_INIT_FILE
	$NS_EXEC $NM_NS $DHCPD start
	$CM_FILE
	$NS_EXEC $NM_NS $HTTPD 
fi
