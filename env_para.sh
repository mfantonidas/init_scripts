#!/bin/bash

CFG_PATH=.
CFG_FILE=$CFG_PATH/test.cfg
CHGDEV_FILE=$CFG_PATH/init_interface.sh
export CFG_PATH
export CFG_FILE
CHG_DEV="1"
export CHG_DEV
WORK_PATH=/usr/local
export WORK_PATH
CFGDB=$WORK_PATH/etc/openvswitch/conf.db
BR_INIT_FILE=./build_init_br.sh
CM_FILE=/usr/local/sbin/cm
HTTPD=/etc/init.d/xinetd
NM_NS=NM-internal
MNG_NS=MNG-namespace
NS_EXEC="ip netns exec"
DHCPD="/etc/init.d/isc-dhcp-server"
export NM_NS
export MNG_NS
export NS_EXEC
BUSINESS_VLAN=200
MANAGER_VLAN=100
MANAGER_IP=192.168.200.106
export BUSINESS_VLAN
export MANAGER_VLAN
export MANAGER_IP

DEV_OUT=
DEV_SDN_ETH1=
DEV_SDN_ETH2=
DEV_SDN_ETH3=
DEV_SDN_ETH4=

export DEV_OUT
export DEV_SDN_ETH1
export DEV_SDN_ETH2
export DEV_SDN_ETH3
export DEV_SDN_ETH4
