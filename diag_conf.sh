#!/bin/bash

ENV_PARA=./env_para.sh

source $ENV_PARA

if test -e $WAN_PATH/xl2tpd.conf
	then
	rm -rf $WAN_PATH/xl2tpd.conf
fi

FILELIST=`ls $WAN_PATH/`
for file in $FILELIST
do 
	if [ -d $WAN_PATH/$file ];then
		echo $file
		cat $WAN_PATH/$file/xl2tpd.conf >> $WAN_PATH/xl2tpd.conf
		echo >> $WAN_PATH/xl2tpd.conf
 	fi
done

#if [ -f /etc/ppp/pppoe.conf -o -f chap-secrets ];then

#fi