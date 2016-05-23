#!/bin/bash

ENV_PARA=./env_para.sh
source $ENV_PARA

if [ "$CHG_DEV" = "1" ];then
	$CHGDEV_FILE
fi

if test -e $CFGDB
then
	echo "conf.db exist"
else
	echo "conf.db not exist"
	$BR_INIT_FILE
	$NS_EXEC $NM_NS $DHCPD start
	$CM_FILE &
	$NS_EXEC $NM_NS $HTTPD  restart
fi
