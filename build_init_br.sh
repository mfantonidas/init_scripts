#!/bin/bash

BUSINESS_VLAN=200
MANAGER_VLAN=100
MANAGER_IP=192.168.200.106:6640
DEL_BR=./del_br.sh

vconfig add em1 $BUSINESS_VLAN
vconfig add em1 $MANAGER_VLAN

ip netns add MNG-namespace
ip link set em1.$MANAGER_VLAN netns MNG-namespace
ip netns exec MNG-namespace ifconfig em1.$MANAGER_VLAN 0 up
ip netns exec MNG-namespace dhclient em1.$MANAGER_VLAN
#echo "ovsdb-tool create $WORK_PATH/etc/openvswitch/conf.db $WORK_PATH/share/openvswitch/vswitch.ovsschema"
`ovsdb-tool create $WORK_PATH/etc/openvswitch/conf.db $WORK_PATH/share/openvswitch/vswitch.ovsschema`

#echo "ovsdb-server --remote=punix:$WORK_PATH/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --private-key=db:Open_vSwitch,SSL,private_key --certificate=db:Open_vSwitch,SSL,certificate --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert --pidfile --detach &"
`ip netns exec MNG-namespace ovsdb-server --remote=punix:$WORK_PATH/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --private-key=db:Open_vSwitch,SSL,private_key --certificate=db:Open_vSwitch,SSL,certificate --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert --pidfile --detach &`

`ovs-vsctl --no-wait init &`
#echo  "ovs-vsctl --no-wait init &"
`ip netns exec MNG-namespace ovs-vswitchd --pidfile --detach --log-file=$WORK_PATH/etc/openvswitch/vswitchd.log`
#echo "ovs-vswitchd --pidfile --detach --log-file=$WORK_PATH/etc/openvswitch/vswitchd.log"
#$DEL_BR

`ovs-vsctl add-br SDN-bridge`

#need to change#
`ovs-vsctl add-port SDN-bridge p255p1 set interface eth1 ofport_request=1`
`ovs-vsctl add-port SDN-bridge p255p2 set interface eth2 ofport_request=2`

`ip netns add NM-internal`
ip link add SDN-internal type veth peer name NM-internal
ovs-vsctl add-port SDN-bridge SDN-internal set interface SDN-internal ofport_request=100
ip link set NM-internal netns NM-internal
ip link add SDN-out-default type veth peer name MNG-default-out.41
ovs-vsctl add-port SDN-bridge SDN-out-default set interface SDN-out-default ofport_request=200

ip netns exec NM-internal ifconfig NM-internal 192.168.1.254/24 up
ip netns exec NM-internal /etc/init.d/isc-dhcp-server start

ip netns exec MNG-namespace ovs-vsctl set-manager tcp:$MANAGER_IP:6640
ip netns exec MNG-namespace ovs-vsctl set-controller SDN-bridge tcp:$MANAGER_IP:6633