#!/bin/bash

# Define Variables
CUR_TIME=`date +"%A_%b_%e_%H%M%y"`
HOSTNAME=`hostname`
REPORT_EMAIL="noreply@vrnchndk.in"
ZPOOL_STATUS=`zpool status -x`

# Save the other values in a file
{
echo "Current Time :: $CUR_TIME"
zpool status
echo "Please Check... ASAP."
} > /tmp/zpools.txt

if [ "$ZPOOL_STATUS" = "all pools are healthy" -o "$ZPOOL_STATUS" = "no pools available" ]
then
        echo -n 0 > /tmp/zpool_status.txt
else
        if [ `cat /tmp/zpool_status.txt` -eq 0 ]
        then
		# Send email with /tmp/zpools.txt as attachment
                echo -n 1 > /tmp/zpool_status.txt
        fi
fi
