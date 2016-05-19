#!/bin/bash

for i in `ip netns show`
do
`ip netns del $i`
echo "del nameapace ${i}"
done

bridges=`ovs-vsctl show|grep Bridge`
for i in $bridges
do
mybris=${i##*Bridge}
if [ ! -z $mybris ];then
`ovs-vsctl del-br $mybris`
echo "del bridge ${mybris}"
fi
done

if 
ip link show|grep SDN-internal
then
`ip link del SDN-internal`
echo 'delete SDN-internal'
fi

if 
ip link show|grep vport-default
then
`ip link del SDN-out-default`
echo 'delete SDN-out-default'
fi
