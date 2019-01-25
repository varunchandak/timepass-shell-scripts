#!/bin/bash

# Define Variables
CUR_TIME=`date +"%A_%b_%e_%H%M%y"`
HOSTNAME=`hostname`
REPORT_EMAIL=noreply@vrnchndk.in
STATUSFILE=/var/zfs/zpool_status.txt
ZPOOL_STATUS=`/sbin/zpool status -x 2>&1`

# Save the other values in a file
{
echo "Current Time :: $CUR_TIME"
echo
/sbin/zpool status
echo
echo "Please Check... ASAP."
} > /var/zfs/zpools.txt

if [ "$ZPOOL_STATUS" = "all pools are healthy" -o "$ZPOOL_STATUS" = "no pools available" ]
then
	echo -n 0 > $STATUSFILE
else
        if [ `cat $STATUSFILE` -eq 0 ]
        then
		#Send email with /var/zfs/zpools.txt as an attachment
                echo -n 1 > $STATUSFILE
        fi
fi
