#!/bin/sh

CFG_PATH=/tmp/test/init_scripts
BR="SDN-bridge"
WORK_PATH="/tmp/test"
NM_NS="NM"
MNG_NS="MNG"

DEV_OUT=oam
DEV_SDN_ETH1=eth0.1
DEV_SDN_ETH2=eth0.2
DEV_SDN_ETH3=eth0.3
DEV_SDN_ETH4=eth0.4
IP_CMD=/usr/bin/ip
OVS_VSCTL="/usr/ovs/bin/ovs-vsctl --db=unix:/tmp/var/ovs/db.sock"
OVS_OFCTL=/usr/ovs/bin/ovs-ofctl

PORTNAME=$1
NODE=$2

#$IP_CMD netns exec $MNG_NS $OVS_VSCTL del-port SDN-bridge $PORTNAME
#$IP_CMD netns del $namespace

namespace=$PORTNAME
var=`$IP_CMD netns show|grep $namespace`
if [ "$var" != "" ]; then
	tcapi unset $NODE
	$IP_CMD netns exec $namespace $IP_CMD link set $PORTNAME netns $MNG_NS
	$IP_CMD netns exec $MNG_NS $OVS_VSCTL del-port SDN-bridge $PORTNAME
	tcapi commit $NODE
    $IP_CMD netns del $namespace
fi

