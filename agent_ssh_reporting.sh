#!/bin/bash

#SCRIPT which monitors log files and reports the SSH activities

SSH_LOGFILE="/var/log/secure"
SUDOUSERLIST="/tmp/sudo_user_list.csv"
SSH_LOGINFILE="/tmp/ssh_details.csv"

#Getting list of sudo users who accessed the server:
grep "sudo:" "$SSH_LOGFILE" | grep -v -e pam_unix -e 'command not allowed' | awk '{print $6}' | sort | uniq > "$SUDOUSERLIST"

#Obtaining a list of commands per user in separate files:
while read SUDO_USER
do
	touch /tmp/"$SUDO_USER"_SSH_DETAILS.csv
	grep "sudo:.*.$SUDO_USER.*.TTY.*.USER.*.COMMAND" "$SSH_LOGFILE" | grep -v -e pam_unix -e 'command not allowed' | grep COMMAND | awk '{ print $3,s="";for (i=14;i<=NF;i++) s=s $i " "; print s }' | paste -d, - - | sed -e 's/COMMAND=//g' -e 's/ ,/,/g'  > /tmp/"$SUDO_USER"_SSH_DETAILS.csv
done < $SUDOUSERLIST

#List of users made ssh connections to the server:
grep Accepted "$SSH_LOGFILE" | awk '{print $9}' | sort | uniq > "$SSH_LOGINFILE"
while read SSH_USER
do
	touch /tmp/"$SUDO_USER"_SSH_LOGINS.csv
	grep "Accepted.*.$SSH_USER" "$SSH_LOGFILE" | awk '{print $3","$11}' > /tmp/"$SUDO_USER"_SSH_LOGINS.csv
done

#Collating all data
tar -czf /tmp/ssh_login_reports.tar.gz /tmp/*_SSH_LOGINS.csv
tar -czf /tmp/sudo_user_reports.tar.gz /tmp/*__SSH_DETAILS.csv

#Mailing the reports to the intended mail recipient
echo "SSH Reports are attached" | mailx \
-r postmaster@domain.com \
-s 'SSH REPORTS and USAGE' \
-a /tmp/ssh_login_reports.tar.gz \
-a /tmp/sudo_user_reports.tar.gz \
-S smtp="domain.com:25" \
-S smtp-auth=login \
-S smtp-auth-user="postmaster@domain.com" \
-S smtp-auth-password="domain@int123" \
-S ssl-verify=ignore \
email@domain.com

#Removing temporary files created
rm -fv /tmp/*_SSH_LOGINS.csv
rm -fv /tmp/*__SSH_DETAILS.csv
rm -fv $SUDOUSERLIST
rm -fv $SSH_LOGINFILE
