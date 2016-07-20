#!/bin/sh

CHG_DEV="0"
BR="SDN-bridge"
WORK_PATH="/tmp/test"
CFGDB="/tmp/test/db/conf.db"
NM_NS="NM"
MNG_NS="MNG"
BUSINESS_VLAN=41
MANAGER_VLAN=100
DEV_SDN_ETH1=eth0.1
DEV_SDN_ETH2=eth0.2
DEV_SDN_ETH3=eth0.3
DEV_SDN_ETH4=eth0.4
IP_CMD=/usr/bin/ip
DHCPD="$WORK_PATH/udhcpd $WORK_PATH/udhcpd.conf &"
OVS_VSCTL="/usr/ovs/bin/ovs-vsctl --db=unix:/tmp/var/ovs/db.sock"
OVS_OFCTL=/usr/ovs/bin/ovs-ofctl
OVSDB_TOOL=/usr/ovs/bin/ovsdb-tool
OVSDB_SERVER=/usr/ovs/sbin/ovsdb-server
OVS_VSWITCHD=/usr/ovs/sbin/ovs-vswitchd
WLAN=$WORK_PATH/init_scripts/wlan.sh 

export OVS_RUNDIR=/tmp/var/ovs

rmmod tcportbind
rmmod hw_nat

/bin/mkdir -m 0777 -p /tmp/test/db
/bin/mkdir -m 0777 -p /tmp/var/ovs
#ifconfig $DEV_OUT 0 up
#/userfs/bin/vconfig add $DEV_OUT $BUSINESS_VLAN
#/userfs/bin/vconfig add $DEV_OUT $MANAGER_VLAN
/usr/bin/smuxctl add ipoe pon manager 3 46 0 46
/usr/bin/smuxctl add bridge pon itv85 3 85 0 85
/usr/bin/smuxctl add bridge pon itv51 3 51 0 51
sleep 2


$IP_CMD netns add MNG
sleep 2

$IP_CMD link set manager netns MNG
$IP_CMD link set itv85 netns MNG
$IP_CMD link set itv51 netns MNG


$IP_CMD netns add NM
sleep 2

$IP_CMD netns exec MNG ifconfig manager up
$IP_CMD netns exec MNG ifconfig itv85 up
$IP_CMD netns exec MNG ifconfig itv51 up
$IP_CMD netns exec MNG udhcpc -i manager -s /usr/script/udhcpc.sh &

#echo "ovsdb-tool create $WORK_PATH/etc/openvswitch/conf.db $WORK_PATH/share/openvswitch/vswitch.ovsschema"
if [ ! -f $CFGDB ]; then
	`$OVSDB_TOOL create $CFGDB /usr/ovs/share/openvswitch/vswitch.ovsschema`
fi
#killall ovsdb-server
#killall ovs-vswitchd
insmod $WORK_PATH/openvswitch.ko
sleep 2

#add Smart IPTV setbox support for vlan tag 85
/userfs/bin/vconfig add $DEV_SDN_ETH1 85
$IP_CMD link set $DEV_SDN_ETH1 netns MNG
$IP_CMD link set $DEV_SDN_ETH1.85 netns MNG
$IP_CMD netns exec MNG ifconfig $DEV_SDN_ETH1 up
$IP_CMD netns exec MNG ifconfig $DEV_SDN_ETH1.85 up
/userfs/bin/vconfig add $DEV_SDN_ETH2 85
$IP_CMD link set $DEV_SDN_ETH2 netns MNG
$IP_CMD link set $DEV_SDN_ETH2.85 netns MNG
$IP_CMD netns exec MNG ifconfig $DEV_SDN_ETH2 up
$IP_CMD netns exec MNG ifconfig $DEV_SDN_ETH2.85 up
/userfs/bin/vconfig add $DEV_SDN_ETH3 85
$IP_CMD link set $DEV_SDN_ETH3 netns MNG
$IP_CMD link set $DEV_SDN_ETH3.85 netns MNG
$IP_CMD netns exec MNG ifconfig $DEV_SDN_ETH3 up
$IP_CMD netns exec MNG ifconfig $DEV_SDN_ETH3.85 up
/userfs/bin/vconfig add $DEV_SDN_ETH4 85
$IP_CMD link set $DEV_SDN_ETH4 netns MNG
$IP_CMD link set $DEV_SDN_ETH4.85 netns MNG
$IP_CMD netns exec MNG ifconfig $DEV_SDN_ETH4 up
$IP_CMD netns exec MNG ifconfig $DEV_SDN_ETH4.85 up



#start ovsdb-server
$IP_CMD netns exec MNG $OVSDB_SERVER --unixctl=/tmp/var/ovs/ovsdb-server.ctl --remote=punix:/tmp/var/ovs/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --detach /tmp/test/db/conf.db &
sleep 2
#start ovs-vswitchd
$IP_CMD netns exec MNG $OVS_VSWITCHD --unixctl=/tmp/var/ovs/ovs-vswitchd.ctl unix:/tmp/var/ovs/db.sock --pidfile=/tmp/var/ovs/ovs-vswitchd.pid --detach &
sleep 2

$IP_CMD netns exec MNG $OVS_VSCTL --no-wait init &
sleep 3
#echo  "ovs-vsctl --no-wait init &"
#$DEL_BR
BR_EXIST=`$OVS_VSCTL show|grep Bridge|grep SDN-bridge`
if [ "$BR_EXIST" != "" ]; then
	echo "do nothing"
	#ip netns exec MNG ovs-vsctl del-br SDN-bridge
else
	echo "$IP_CMD netns exec MNG $OVS_VSCTL add-br SDN-bridge"
	`$IP_CMD netns exec MNG $OVS_VSCTL add-br SDN-bridge`
	$IP_CMD netns exec MNG $OVS_VSCTL set Bridge SDN-bridge mcast_snooping_enable=true
	#need to change#
	`$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge $DEV_SDN_ETH1 -- set interface $DEV_SDN_ETH1 ofport_request=1`
	`$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge $DEV_SDN_ETH1.85 -- set interface $DEV_SDN_ETH1.85 ofport_request=81`
	`$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge $DEV_SDN_ETH2 -- set interface $DEV_SDN_ETH2 ofport_request=2`
	`$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge $DEV_SDN_ETH2.85 -- set interface $DEV_SDN_ETH2.85 ofport_request=82`
	`$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge $DEV_SDN_ETH3 -- set interface $DEV_SDN_ETH3 ofport_request=3`
	`$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge $DEV_SDN_ETH3.85 -- set interface $DEV_SDN_ETH3.85 ofport_request=83`
	`$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge $DEV_SDN_ETH4 -- set interface $DEV_SDN_ETH4 ofport_request=4`
	`$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge $DEV_SDN_ETH4.85 -- set interface $DEV_SDN_ETH4.85 ofport_request=84`
	$IP_CMD netns exec MNG $OVS_VSCTL set Port $DEV_SDN_ETH1 other_config:mcast-snooping-flood-reports=true
	$IP_CMD netns exec MNG $OVS_VSCTL set Port $DEV_SDN_ETH1.85 other_config:mcast-snooping-flood-reports=true
	$IP_CMD netns exec MNG $OVS_VSCTL set Port $DEV_SDN_ETH2 other_config:mcast-snooping-flood-reports=true
	$IP_CMD netns exec MNG $OVS_VSCTL set Port $DEV_SDN_ETH2.85 other_config:mcast-snooping-flood-reports=true
	$IP_CMD netns exec MNG $OVS_VSCTL set Port $DEV_SDN_ETH3 other_config:mcast-snooping-flood-reports=true
	$IP_CMD netns exec MNG $OVS_VSCTL set Port $DEV_SDN_ETH3.85 other_config:mcast-snooping-flood-reports=true
	$IP_CMD netns exec MNG $OVS_VSCTL set Port $DEV_SDN_ETH4 other_config:mcast-snooping-flood-reports=true
	$IP_CMD netns exec MNG $OVS_VSCTL set Port $DEV_SDN_ETH4.85 other_config:mcast-snooping-flood-reports=true
	$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge si -- set interface si type=internal ofport_request=100
	$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge SDN-out-default -- set interface SDN-out-default type=internal ofport_request=200
	$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge itv85 -- set interface itv85 ofport_request=85
	$IP_CMD netns exec MNG $OVS_VSCTL add-port SDN-bridge itv51 -- set interface itv51 ofport_request=51
fi

$IP_CMD netns exec MNG $OVS_VSCTL set-fail-mode SDN-bridge secure
echo $IP_CMD
sleep 1
$IP_CMD netns exec MNG $IP_CMD link set si netns NM
$IP_CMD netns exec MNG $IP_CMD link set SDN-out-default netns 1

ifconfig SDN-out-default 192.168.1.1/24 hw ether 22:22:22:22:22:22 up

$IP_CMD netns exec NM ifconfig si 192.168.1.254/24 up
killall udhcpd
cp /tmp/test/udhcpd.conf /etc
$IP_CMD netns exec NM $DHCPD

$IP_CMD netns exec MNG $OVS_OFCTL add-flow SDN-bridge in_port=1,priority=1,actions=NORMAL
$IP_CMD netns exec MNG $OVS_OFCTL add-flow SDN-bridge in_port=2,priority=1,actions=NORMAL
$IP_CMD netns exec MNG $OVS_OFCTL add-flow SDN-bridge in_port=3,priority=1,actions=NORMAL
$IP_CMD netns exec MNG $OVS_OFCTL add-flow SDN-bridge in_port=4,priority=1,actions=NORMAL
$IP_CMD netns exec MNG $OVS_OFCTL add-flow SDN-bridge in_port=100,priority=1,actions=NORMAL
$IP_CMD netns exec MNG $OVS_OFCTL add-flow SDN-bridge in_port=200,priority=1,actions=NORMAL
$IP_CMD netns exec MNG $OVS_OFCTL add-flow SDN-bridge in_port=81,priority=2,actions=output:85
$IP_CMD netns exec MNG $OVS_OFCTL add-flow SDN-bridge in_port=82,priority=2,actions=output:85
$IP_CMD netns exec MNG $OVS_OFCTL add-flow SDN-bridge in_port=83,priority=2,actions=output:85
$IP_CMD netns exec MNG $OVS_OFCTL add-flow SDN-bridge in_port=84,priority=2,actions=output:85
$IP_CMD netns exec MNG $OVS_OFCTL add-flow SDN-bridge in_port=85,priority=2,actions=strip_vlan,output:1,2,3,4,81,82,83,84
$IP_CMD netns exec MNG $OVS_OFCTL add-flow SDN-bridge in_port=51,priority=2,actions=strip_vlan,output:1,2,3,4,81,82,83,84

for i in `tcapi show VPN|grep Entry`
do
        var=${i##*:}
        tcapi unset "VPN_"$var
done


$WLAN &

cp /tmp/test/httpd/services /etc/
cp /tmp/test/httpd/inetd.conf /etc/
killall bftpd
$IP_CMD netns exec NM /userfs/bin/inetd -d &
