#!/bin/bash
ENV_PARA=./env_para.sh
source $ENV_PARA
PORTNAME=$1

if [ $PORTNAME = "SDN-out-default" ];then
	if [ -f $DEFAULT_WAN_PATH/pppoe.conf -o -f $DEFAULT_WAN_PATH/chap-secrets ];then
		pppoe-start
		route del default
		route add default dev ppp0
	fi
else
	if test -e $WAN_PATH/$PORTNAME
	then
		#echo $WAN_PATH/$PORTNAME		
		./diag_conf.sh
		str=`grep user $WAN_PATH/$PORTNAME/$PORTNAME.options`
		username=${str##* }
		#echo $username
		namespace="NS-"$PORTNAME
		ip netns add $namespace
		ip netns exec $MNG_NS ovs-vsctl add-port $BR $PORTNAME -- set interface $PORTNAME type=internal
		ip netns exec $MNG_NS ip link set $PORTNAME netns $namespace
		mkdir /var/run/xl2tpd
		xl2tpd -c $WAN_PATH/xl2tpd.conf
		echo "c $username" > /var/run/xl2tpd/l2tp-control
	fi
fi