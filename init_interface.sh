#!/bin/bash

echo $CFG_PATH
echo $CFG_FILE
CHANGE="0"
GET_UP_CFG=./get_up_cfg.sh

$GET_UP_CFG
if test -e $CFG_FILE
then
	echo "exist"
	while read line; do
		eval "$line"
	done < $CFG_FILE
	echo $NETDEV_COUNT

	for((i=0;i<$NETDEV_COUNT;i++))
	do
		#j=`expr $i + 1`
		name=DEV$i
		var=`eval echo '$'"$name"`
		echo "DEV$i = $var"
		if [ $var = "em1" -o $var = "eth0" -o $var = "p32p1"  ];then
			DEV_OUT=$var
		else
			eval DEV_SDN_ETH${i}=$var
		#if [ $CHANGE -eq 1 ];then
		#	if [ $var = "em1" -o $var = "eth0" -o $var = "p32p1"  -o $var ];then
		#		DEV_OUT=
	#		if [ $i -eq 0 ];then
	#			echo "ip link set $var name out"
	#			#ip link set $var name out
	#		else
	#			echo "ip link set $var name SDN-eth$i"
	#			#ip link set $var name SDN-eth$i
	#		fi
	#		#`ip link set $var name SDN-eth$j` 
	#		#fi
		fi
	#	echo $i
	done
fi
if [ $CHANGE = "1"];then
	ip link set $DEV_OUT name out
	if [ -n $DEV_SDN_ETH1 ];then
		ip link set $DEV_SDN_ETH1 name SDN-eth1
	fi
	if [ -n $DEV_SDN_ETH2 ];then
		ip link set $DEV_SDN_ETH2 name SDN-eth2
	fi
	if [ -n $DEV_SDN_ETH3 ]; then
		ip link set $DEV_SDN_ETH3 name SDN-eth3
	fi
	if [ -n $DEV_SDN_ETH4 ]; then
		ip link set $DEV_SDN_ETH4 name SDN-eth4
	fi
fi
