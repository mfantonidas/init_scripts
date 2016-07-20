#!/bin/sh

ifconfig br0 down
brctl delbr br0
mkdir -p /var/run/netns
