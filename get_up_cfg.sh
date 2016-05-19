#!/bin/bash

#CFG_PATH=.
#CFG_FILE=$CFG_PATH/test.cfg
echo "CFG_PATH"
echo "CFG_FILE"
if test -e $CFG_FILE
then
echo "file exist"
else
echo "file not exist"
touch $CFG_FILE
#NETDEV_COUNT=$(ifconfig -a | grep -i hwaddr|grep -a "Link"|wc -l)
i=0
for dev in $(ifconfig -a| grep -i hwaddr|awk '{print $1}')
{
	if [ "$dev" = "ovs-system" ];then
		continue
	fi
	DEVS[$i]=$dev
	#$i=`expr $i+1`
	echo "DEV$i=$dev" >> $CFG_FILE
	#i=$i+1
	i=`expr $i + 1`
}
echo "NETDEV_COUNT=$i" >> $CFG_FILE
echo $NETDEV_COUNT
echo ${DEVS[3]}
echo ${#DEVS[*]}
fi
