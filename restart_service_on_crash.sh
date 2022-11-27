#!/bin/bash

# monitoring mysql service, restart if crashed; can be used for any service
ps -elf | grep -w mysqld_safe | grep -v grep > /dev/null 2>&1
a=$(echo $?)
if test $a -ne 0; then
	echo "MySQL Service is Down; Restarting" >> /var/log/mysql_state.log
	/bin/sh /opt/lampp/mysql/scripts/ctl.sh start > /dev/null 2>/dev/null
else
	sleep 0
fi
