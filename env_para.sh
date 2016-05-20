#!/bin/bash

DEV_OUT=
DEV_SDN_ETH1=
DEV_SDN_ETH2=
DEV_SDN_ETH3=
DEV_SDN_ETH4=

if [ $CHG_DEV = "1" ];then
	./init_interface.sh	
fi

export DEV_OUT
export DEV_SDN_ETH1
export DEV_SDN_ETH2
export DEV_SDN_ETH3
export DEV_SDN_ETH4