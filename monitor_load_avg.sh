#!/bin/bash

# Define Variables
export CUR_TIME="$(date +"%A %b %e %r")"
export HOSTNAME="$(hostname)"

# Retrieve the load average of the past 1 minute
export Load_AVG="$(uptime | cut -d'l' -f2 | awk '{print $3}' | cut -d. -f1)"
export LOAD_CUR="$(uptime | cut -d'l' -f2 | awk '{print $3 " " $4 " " $5}' | sed 's/,//')"

# Define Threshold. This value will be compared with the current
# load average. Set the value as per your wish.
export LIMIT=50

# Compare the current load average with the Threshold value and
# email the server administrator if the current load average
# is greater.
if [ "$Load_AVG" -gt "$LIMIT" ]; then
	#Save the current running processes in a file
	/bin/ps auxf >> /root/ps_output
	
	# Save the other values in a file
	echo "Current Time :: $CUR_TIME" >> /tmp/monitload.txt
	echo "Current Load Average :: $LOAD_CUR" >> /tmp/monitload.txt
	echo "The list of current processes is attached with the email for your reference." >> /tmp/monitload.txt
	echo "Please Check... ASAP."  >> /tmp/monitload.txt
	
	# Send an email to the administrator of the server
	# sendmail postmaster@domain.com "ALERT. Load average on '$HOSTNAME'" -to email@domain.com < /tmp/monitload.txt
fi

# Remove the temporary log files
/bin/rm -f /tmp/monitload.txt
/bin/rm -f /root/ps_output
