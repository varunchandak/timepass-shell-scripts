#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ "$(date +%Z)" != "IST" ]
then
	printf "${RED}TIMING IS INCORRECT${NC}, Correcting back to IST\n"
	rm -f /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
	/usr/sbin/ntpdate -u 0.pool.ntp.org
else
        printf "${RED}ALL OK${NC}, Date and time is proper\n"
	/usr/sbin/ntpdate -u 0.pool.ntp.org
fi
