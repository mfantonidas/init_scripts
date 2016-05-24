#!/bin/bash

DEL_BR=./del_br.sh

vconfig add $DEV_OUT $BUSINESS_VLAN
vconfig add $DEV_OUT $MANAGER_VLAN

ip netns add MNG-namespace
ip link set $DEV_OUT.$MANAGER_VLAN netns MNG-namespace
ip netns exec MNG-namespace ifconfig $DEV_OUT.$MANAGER_VLAN 0 up
ip netns exec MNG-namespace dhclient $DEV_OUT.$MANAGER_VLAN
#echo "ovsdb-tool create $WORK_PATH/etc/openvswitch/conf.db $WORK_PATH/share/openvswitch/vswitch.ovsschema"
if test -n $CFGDB
	`ovsdb-tool create $WORK_PATH/etc/openvswitch/conf.db $WORK_PATH/share/openvswitch/vswitch.ovsschema`
fi

#echo "ovsdb-server --remote=punix:$WORK_PATH/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --private-key=db:Open_vSwitch,SSL,private_key --certificate=db:Open_vSwitch,SSL,certificate --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert --pidfile --detach &"
`ip netns exec MNG-namespace ovsdb-server --remote=punix:$WORK_PATH/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --private-key=db:Open_vSwitch,SSL,private_key --certificate=db:Open_vSwitch,SSL,certificate --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert --pidfile --detach &`

`ip netns exec MNG-namespace ovs-vsctl --no-wait init &`
#echo  "ovs-vsctl --no-wait init &"
`ip netns exec MNG-namespace ovs-vswitchd --pidfile --detach --log-file=$WORK_PATH/etc/openvswitch/vswitchd.log`
#echo "ovs-vswitchd --pidfile --detach --log-file=$WORK_PATH/etc/openvswitch/vswitchd.log"
#$DEL_BR

`ip netns exec MNG-namespace ovs-vsctl add-br SDN-bridge`

#need to change#
if [ -n $DEV_SDN_ETH1 ];then
	ip link set $DEV_SDN_ETH1 netns MNG-namespace
	`ip netns exec MNG-namespace ovs-vsctl add-port SDN-bridge $DEV_SDN_ETH1 set interface $DEV_SDN_ETH1 ofport_request=1`
fi
if [ -n $DEV_SDN_ETH2 ];then
	ip link set $DEV_SDN_ETH2 netns MNG-namespace
	`ip netns exec MNG-namespace ovs-vsctl add-port SDN-bridge $DEV_SDN_ETH2 set interface $DEV_SDN_ETH2 ofport_request=2`
fi
if [ -n $DEV_SDN_ETH3 ];then
	ip link set $DEV_SDN_ETH3 netns MNG-namespace
	`ip netns exec MNG-namespace ovs-vsctl add-port SDN-bridge $DEV_SDN_ETH3 set interface $DEV_SDN_ETH3 ofport_request=3`
fi
if [ -n $DEV_SDN_ETH4 ];then
	ip link set $DEV_SDN_ETH4 netns MNG-namespace
	`ip netns exec MNG-namespace ovs-vsctl add-port SDN-bridge $DEV_SDN_ETH4 set interface $DEV_SDN_ETH4 ofport_request=4`
fi
ip netns exec MNG-namespace ovs-vsctl add-port SDN-bridge SDN-internal -- set interface SDN-internal type=internal ofport_request=100
`ip netns add NM-internal`
ip netns exec MNG-namespace ip link set SDN-internal netns NM-internal
#ip link add SDN-internal type veth peer name NM-internal
#ip netns exec MNG-namespace  ovs-vsctl add-port SDN-bridge SDN-internal set interface SDN-internal ofport_request=100
#ip link set NM-internal netns NM-internal
ip netns exec MNG-namespace ovs-vsctl add-port SDN-bridge SDN-out-default set interface SDN-out-default type=internal ofport_request=200
ip netns exec MNG-namespace ip link set SDN-out-default netns 1
ifconfig SDN-out-default 192.168.1.1/24 up


ip netns exec NM-internal ifconfig SDN-internal 192.168.1.254/24 up
ip netns exec NM-internal /etc/init.d/isc-dhcp-server start

ip netns exec MNG-namespace ovs-vsctl set-manager tcp:$MANAGER_IP:6640
ip netns exec MNG-namespace ovs-vsctl set-controller SDN-bridge tcp:$MANAGER_IP:6633