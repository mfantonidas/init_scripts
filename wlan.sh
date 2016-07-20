#!/bin/sh

IP_CMD=/usr/bin/ip
DHCPD="$WORK_PATH/udhcpd $WORK_PATH/udhcpd.conf &"
OVS_VSCTL="/usr/ovs/bin/ovs-vsctl --db=unix:/tmp/var/ovs/db.sock"
OVS_OFCTL=/usr/ovs/bin/ovs-ofctl
OVSDB_TOOL=/usr/ovs/bin/ovsdb-tool
OVSDB_SERVER=/usr/ovs/sbin/ovsdb-server
OVS_VSWITCHD=/usr/ovs/sbin/ovs-vswitchd

insmod /lib/modules/mt7603eap.ko
$IP_CMD link set ra0 netns MNG

if [ "$1" = "1" ]; then
	var=`$IP_CMD netns exec MNG ifconfig -a |grep ra0`
	$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge ra0 -- set interface ra0 ofport_request=11
	if [ "$var" = "" ]; then
		tcapi commit WLan
		$IP_CMD netns exec MNG ifconfig ra0 up
	else
		$IP_CMD netns exec MNG ifconfig ra0 down
		tcapi commit WLan
		sleep 2
		$IP_CMD netns exec MNG ifconfig ra0 up
	fi
else
	$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge ra0 -- set interface ra0 ofport_request=11
	$IP_CMD netns exec MNG ifconfig ra0 down
	tcapi commit WLan
fi
	
portbindcmd disable
