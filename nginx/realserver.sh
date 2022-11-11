#!/bin/bash
#description: Config realserver

for i in /proc/sys/net/ipv4/conf/*/rp_filter
do
   echo "setting $i to 0"
   echo 0 > $i
done

VIP=10.11.12.50

/sbin/ifconfig lo:0 $VIP netmask 255.255.255.255 broadcast $VIP
/sbin/route add -host $VIP dev lo:0
echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
sysctl -p >/dev/null 2>&1
echo "RealServer Start OK"

exit 0
