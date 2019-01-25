#!/bin/bash

# Original Link: http://blog.strictly-software.com/2013/07/apache-performance-tuning-bash-script.html

echo "Calculate MaxClients by dividing biggest Apache thread by free memory"
if [ -e /etc/debian_version ]
then
	APACHE="apache2"
elif [ -e /etc/redhat-release ]
then
	APACHE="httpd"
fi

APACHEMEM=$(ps -aylC $APACHE |grep "$APACHE" |awk '{print $8'} |sort -n |tail -n 1)
APACHEMEM=$(expr $APACHEMEM / 1024)
SQLMEM=$(ps -aylC mysqld |grep "mysqld" |awk '{print $8'} |sort -n |tail -n 1)
SQLMEM=$(expr $SQLMEM / 1024)

echo "Stopping $APACHE to calculate the amount of free memory"
/etc/init.d/$APACHE stop &> /dev/null
sleep 5
TOTALFREEMEM=$(free -m |head -n 2 |tail -n 1 |awk '{free=($4); print free}')
TOTALMEM=$(free -m |head -n 2 |tail -n 1 |awk '{total=($2); print total}')
SWAP=$(free -m |head -n 4 |tail -n 1 |awk '{swap=($3); print swap}')
MAXCLIENTS=$(expr $TOTALFREEMEM / $APACHEMEM)
MINSPARESERVERS=$(expr $MAXCLIENTS / 4)
MAXSPARESERVERS=$(expr $MAXCLIENTS / 2)

echo "Starting $APACHE again"
/etc/init.d/$APACHE start &> /dev/null

echo "Total memory $TOTALMEM"
echo "Free memory $TOTALFREEMEM"
echo "Amount of virtual memory being used $SWAP"
echo "Largest Apache Thread size $APACHEMEM"
echo "Amount of memory taking up by MySQL $SQLMEM"

if [[ SWAP > TOTALMEM ]]; then
      ERR="Virtual memory is too high"
else
      ERR="Virtual memory is ok"
fi

echo "$ERR"
echo "Total Free Memory $TOTALFREEMEM"
echo "MaxClients should be around $MAXCLIENTS"
echo "MinSpareServers should be around $MINSPARESERVERS"
echo "MaxSpareServers should be around $MAXSPARESERVERS"
