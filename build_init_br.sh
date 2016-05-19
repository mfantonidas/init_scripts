#!/bin/bash
BUSINESS_VLAN=41
MANAGER_VLAN=46
DEL_BR=./del_br.sh

ovsdb-tool create $WORK_PATH/etc/openvswitch/conf.db $WORK_PATH/share/openvswitch/vswitch.ovsschema

ovsdb-server --remote=punix:$WORK_PATH/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --private-key=db:Open_vSwitch,SSL,private_key --certificate=db:Open_vSwitch,SSL,certificate --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert --pidfile --detach &

ovs-vsctl --no-wait init &
ovs-vswitchd --pidfile --detach --log-file=$WORK_PATH/etc/openvswitch/vswitchd.log

$DEL_BR

ovs-vsctl add-br SDN-bridge

#need to change#
ovs-vsctl add-port SDN-bridge eth1 set interface eth1 ofport_request=1
ovs-vsctl add-port SDN-bridge eth2 set interface eth2 ofport_request=2

ip netns add NM-internal
ip link add SDN-internal type veth peer name NM-internal
ovs-vsctl add-port SDN-bridge SDN-internal set interface SDN-internal ofport_request=100
ip link set NM-internal netns NM-internal
ip link add SDN-out-default type veth peer name MNG-default-out.41
ovs-vsctl add-port SDN-bridge SDN-out-default set interface SDN-out-default ofport_request=200

vconfig add eth0 $BUSINESS_VLAN
vconfig add eth0 $MANAGER_VLAN

ip netns add MNG-namespace
ip link set eth0.$MANAGER_VLAN netns MNG-namespace

ip netns exec NM-internal ifconfig NM-internal 192.168.1.254/24 up
#ip netns exec NM-internal /etc/init.d/isc-dhcp-server start

ip netns exec MNG-namespace dhclient eth0.$MANAGER_VLAN

