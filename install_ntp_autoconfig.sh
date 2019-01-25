#!/bin/bash
# ******************************************
# Program: NTP Update Setup
# ******************************************

YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)
if [[ ! -z $YUM_CMD ]]; then
    sudo "$YUM_CMD" -y install ntp ntpd ntpdate;
    sudo rm -f /etc/ntp.conf
    sudo wget https://s3.ap-south-1.amazonaws.com/ss-config-files/ntp.conf -P /etc/
    sudo chkconfig ntpd on;
    sudo chkconfig ntpdate on;
    sudo rm -f /etc/localtime
    sudo ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
elif [[ ! -z $APT_GET_CMD ]]; then
    sudo "$APT_GET_CMD" update;
    sudo "$APT_GET_CMD" -y install ntp ntpdate;
    cp -pv /etc/ntp.conf /etc/ntp.conf.factory_defaults;
    sudo rm -f /etc/ntp.conf
    sudo wget https://s3.ap-south-1.amazonaws.com/ss-config-files/ntp.conf -P /etc/
    sudo ntpdate -u 0.amazon.pool.ntp.org
    sudo timedatectl set-timezone Asia/Kolkata
    sudo update-rc.d ntp defaults
    sudo update-rc.d ntpdate defaults
else
    echo "Unsupported Operating System";
    exit 1;
fi
