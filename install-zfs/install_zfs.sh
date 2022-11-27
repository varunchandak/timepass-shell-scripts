#!/bin/bash

/sbin/iptables -I INPUT 1 -p tcp --dport 21 -j ACCEPT

mkdir /root/zfs/

cd /root/zfs/

rpm2cpio epel-release-6-8.noarch.rpm | cpio -idmv
rpm2cpio zfs-release-1-4.el6.noarch.rpm | cpio -idmv

cp -vRn etc/* /etc/
cp -vRn usr/* /usr/
rm -rf /root/zfs/*

yum upgrade ca-certificates --disablerepo=epel -y
rpm -ivh kernel-devel-2.6.32-220.el6.x86_64.rpm
yum install yum-utils -y
package-cleanup --oldkernels --count=1 -y
rpm -qa | grep ^kernel 
yum upgrade kernel-headers -y
yum install zfs -y
chkconfig --add zfs

getenforce 1> /dev/null
if [[ "$(/usr/sbin/getenforce)" -ne "Disabled" ]]
then
	sed -ri 's/^(SELINUX=)[^=]*$/\1disabled/g' /etc/sysconfig/selinux
fi

/sbin/iptables -D INPUT 1

echo "Enter a recognizable pool name: (one time only)"
read POOLNAME
echo "Run the following commands as per your requirement, replacing disk names:"

echo "zfs create -f $POOLNAME mirror <disk> <disk> mirror <disk> <disk> -m /data1"
echo "zpool set autoexpand=on $POOLNAME"
echo "zfs set atime=off $POOLNAME"
echo "zfs set compress=lzjb $POOLNAME"
echo "zfs set recordsize=16K $POOLNAME"
echo "zfs set checksum=off $POOLNAME"
echo "zfs set primarycache=metadata $POOLNAME"
echo "zfs get atime,compress,recordsize,checksum,primarycache $POOLNAME"
echo "zpool status -v"

