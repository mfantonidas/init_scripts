#!/bin/bash

#CFG_PATH=.
#CFG_FILE=$CFG_PATH/test.cfg
#CHG_DEV=1
echo $CFG_PATH
echo $CFG_FILE
if test -e $CFG_FILE
then
	echo "exist"
	while read line; do
		eval "$line"
	done < $CFG_FILE
echo $NETDEV_COUNT
for((i=0;i<$NETDEV_COUNT;i++))
do
	j=`expr $i + 1`
	name=DEV$i
	var=`eval echo '$'"$name"`
	echo "DEV$i = $var"
	if [ $CHG_DEV -eq 1 ];then
		echo "ip link set $var name SDN-ETH$j"
		#`ip link set $var name SDN-eth$j` 
	fi
	echo $i
done
fi
