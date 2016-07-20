#!/bin/sh

CFG_PATH=/tmp/test/init_scripts
CFG_FILE=$CFG_PATH/test.cfg
CHGDEV_FILE=$CFG_PATH/init_interface.sh
CHG_DEV="0"
BR="SDN-bridge"
WORK_PATH="/tmp/test"
HTTPD="/etc/init.d/xinetd"
NM_NS="NM"
MNG_NS="MNG"
NS_EXEC="ip netns exec"
DEFAULT_WAN_PATH=/etc/ppp
WAN_PATH=/var/run/wan
DEV_OUT=oam
DEV_SDN_ETH1=eth0.1
DEV_SDN_ETH2=eth0.2
DEV_SDN_ETH3=eth0.3
DEV_SDN_ETH4=eth0.4
IP_CMD=/usr/bin/ip
OVS_VSCTL=/usr/ovs/bin/ovs-vsctl
OVS_OFCTL=/usr/ovs/bin/ovs-ofctl

PORTNAME=$1

if [ $PORTNAME = "SDN-out-default" ];then
	tcapi commit $2
	iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o ppp8 -j MASQUERADE
else
        namespace=$PORTNAME
	value=`$IP_CMD netns show|grep $namespace`
        if [ "$value" = "" ];then
            	$IP_CMD netns add $namespace
        fi
	
	tcapi commit $2
	
	value=`$IP_CMD netns exec MNG $IP_CMD link list | grep $PORTNAME`	
        if [ "$value" != "" ];then
		$IP_CMD netns exec MNG $IP_CMD link set $PORTNAME netns $namespace
		$IP_CMD netns exec $namespace ifconfig $PORTNAME 192.168.1.1/24 hw ether 22:22:22:22:22:22 up
	fi
    #need to update
    $IP_CMD netns exec $namespace iptables -t nat -A POSTROUTING -o ppp101 -j MASQUERADE
    $IP_CMD netns exec $namespace iptables -t nat -A POSTROUTING -o ppp102 -j MASQUERADE
fi
