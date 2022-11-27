#!/bin/bash

check_file(){
	x="$t"
	if [ ! -f $x ]; then
		echo "File $x not found"
	fi
}

echo "Audit script for Linux is running. Kindly wait for the script to complete."

exec > `hostname`_RHEL4.txt 2>errors.txt
echo "LIN_00 - System Information"
hostname
/sbin/ifconfig -a|grep "inet addr"
echo "SCRIPT VERSION - 2.3"
echo "System Access and Authentication"
echo "LIN_01 - Passwords are not secured"
echo "LIN_01	Shadow"
/bin/cat /etc/passwd | grep root:x > temp
t=$_
check_file $t
shadow=`cut -d: -f2 temp` 1>/dev/null
t=$_
check_file $t
if [ $shadow == "x" ]; then
	echo "Shadow passwords are enabled"
fi
echo "LIN_01	MD5"
/bin/cat /etc/shadow | grep root > temp
md5=`cut -d: -f2 temp`
echo $md5
rm -rf temp
echo

echo "LIN_02 - Remote root login is enabled"
cat /etc/securetty 2>/dev/null
t=$_
check_file $t
echo

echo "LIN_03 - Remote login by unauthenticated users"
cat /etc/hosts.equiv 2>/dev/null
t=$_
check_file $t
echo

echo "LIN_04 - Telnet is not used for remote administration"
#echo "LIN_04 XINETD"
#chkconfig --list | grep xinetd
#echo "IF XINETD SERVICE IS RUNNING THEN CHECK FOR THE BELOW OUTPUT"
#echo "Telnet service status"
#chkconfig --list | grep telnet
#t=$_
#check_file $t
#echo

echo "SSH service status"
chkconfig --list | grep ssh
t=$_
check_file $t
echo

#echo "LIN_04 TELNET"
#rpm -qa | grep telnet-server
#echo

echo "LIN_04 SSH"
rpm -qa | egrep "ssh|ssl"

echo "Contents in /etc/ssh/sshd_config"
cat /etc/ssh/sshd_config | grep -i protocol | grep -v "#"
cat /etc/ssh/sshd_config | grep -i loglevel | grep -v "#"
cat /etc/ssh/sshd_config | grep -i permitrootlogin | grep -v "#"
cat /etc/ssh/sshd_config | grep -i hostbasedauthentication | grep -v "#"
cat /etc/ssh/sshd_config | grep -i ignoreRhosts | grep -v "#"
cat /etc/ssh/sshd_config | grep -i permitemptypasswords | grep -v "#"
echo

echo "LIN_05 - Boot loader is not secured"
echo "LIN_05	GRUB"
cat /etc/grub.conf | grep -E 'password --md5|lock' 2>/dev/null
t=$_
check_file $t
echo "LIN_05	LILO"
cat /etc/lilo.conf | grep password
t=$_
check_file $t
echo

echo "LIN_06 - CTRL-ALT-DEL to reboot the machine is enabled"
cat /etc/inittab | grep 'ctrlaltdel'
t=$_
check_file $t
echo

echo "LIN_07 - Set null shell for all default user accounts"
cat /etc/passwd
t=$_
check_file $t
echo

echo "LIN_08 - Password policy is not enabled"
grep -v \^\# /etc/login.defs | grep PASS
echo

echo "LIN_09 - Single user mode is not password protected"
cat /etc/inittab | grep '~~:S:wait:/sbin/sulogin'
t=$_
check_file $t
echo

echo "LIN_10 - Duplicate rootUIDs are present in the system"
cat /etc/passwd | grep ':x:0'
t=$_
check_file $t
echo

echo "LIN_11 - Login banner is not enabled in the system"
echo "LIN_11	ISSUE"
cat /etc/issue 2>/dev/null
t=$_
check_file $t
echo "LIN_11	MOTD"
cat /etc/motd 2>/dev/null
t=$_
check_file $t
echo
echo "LIN_12 - FTP and Telnet banners are absent in the system"
echo "LIN_12	ISSUE.NET"
cat /etc/issue.net 2>/dev/null
t=$_
check_file $t
echo "LIN_12	FTPD_BANNER"
cat /etc/vsftpd/vsftpd.conf | grep -v '#' | grep 'ftpd_banner' 2>/dev/null
t=$_
check_file $t
echo
echo "LIN_13 - Weak System UMASK"
umask
echo
echo "Filesystem security"
echo "LIN_14 - Unlimited user access to FTP"
echo "LIN_14	FTPSERVICE"
chkconfig --list | grep ftpd
t=$_
check_file $t
echo "LIN_14	USERLISTENABLE"
cat /etc/vsftpd/vsftpd.conf | grep -i userlist_enable | grep -v "#"
echo "LIN_14	USERLISTDENY"
cat /etc/vsftpd/vsftpd.conf | grep -i userlist_deny | grep -v "#"
echo "LIN_14	FTPUSERS"
t="/etc/ftpusers"
check_file $t
for x in `cat /etc/passwd | awk -F: ' { print $1 } '`
do
chk=$(grep $x /etc/ftpusers) 2>/dev/null
ch=$?
if [ $ch -eq 1 ]; then
echo "$x"
fi
done
echo "LIN_14	VSFTPD"
echo "Users missing in /etc/vsftpd.ftpusers"
t="/etc/vsftpd.ftpusers"
check_file $t
for x in `cat /etc/passwd | awk -F: ' { print $1 } '`
do
chk=$(grep $x /etc/vsftpd.ftpusers) 2>/dev/null
ch=$?
if [ $ch -eq 1 ]; then
echo "$x"
fi
done
echo "Users missing in /etc/vsftpd/ftpusers"
t="/etc/vsftpd/ftpusers"
check_file $t
for x in `cat /etc/passwd | awk -F: ' { print $1 } '`
do
chk=$(grep $x /etc/vsftpd/ftpusers) 2>/dev/null
ch=$?
if [ $ch -eq 1 ]; then
echo "$x"
fi
done
echo "Users present in /etc/vsftpd/user_list"
cat /etc/vsftpd/user_list | awk -F: ' { print $1 } ' | grep -v "#"
t=$_
check_file $t
echo "Users missing in /etc/vsftpd/user_list"
t="/etc/vsftpd/user_list"
check_file $t
for x in `cat /etc/passwd | awk -F: ' { print $1 } '`
do
chk=$(grep $x /etc/vsftpd/user_list) 2>/dev/null
ch=$?
if [ $ch -eq 1 ]; then
echo "$x"
fi
done

echo
echo "LIN_15 - SUID bit is set for files"
find / -perm -4755 -print 
echo

echo "LIN_16- Sticky bit on temporary folders"
echo "Sticky bit on /tmp"
ls -l / | grep 'tmp'
echo "Sticky bit on /var/tmp"
ls -ld  '/var/tmp'
echo

echo "LIN_17 - Passwd, shadow and group file permission are not secured"
ls -l /etc/passwd
t=$_
check_file $t
ls -l /etc/shadow
t=$_
check_file $t
ls -l /etc/group
t=$_
check_file $t
echo

echo "LIN_18 - Users are consuming too many system resources"
cat /etc/security/limits.conf
t=$_
check_file $t
echo

echo "LIN_19 - CRON and AT security are not properly configured"
echo "LIN_19	CRON ALLOW"
cat /etc/cron.allow 2>/dev/null
t=$_
check_file $t
echo "PERMISSION ON CRON ALLOW"
ls -l /etc/cron.allow
t=$_
check_file $t
echo "LIN_19	CRON DENY"
cat /etc/cron.deny 2>/dev/null
t=$_
check_file $t
echo "PERMISSION ON CRON DENY"
ls -l /etc/cron.deny
t=$_
check_file $t
echo "LIN_19	AT ALLOW"
cat /etc/at.allow 2>/dev/null
t=$_
check_file $t
echo "PERMISSION ON AT ALLOW"
ls -l /etc/at.allow
t=$_
check_file $t
echo "LIN_19	AT DENY"
cat /etc/at.deny 2>/dev/null
t=$_
check_file $t
echo "PERMISSION ON AT DENY"
ls -l /etc/at.deny
t=$_
check_file $t
echo

echo "LIN_20 - User home directory permission is not secured"
awk -F: '( $3 >= 500 ) { print $6 }' /etc/passwd > t.txt
for x in `cat t.txt`
do
ls -ld $x
done
echo

echo "Auditing and Logging"
echo "LIN_21 - User authentication is not audited"
echo "LIN_21	AUTHPRIV"
cat /etc/syslog.conf | grep -i 'authpriv.*'
t=$_
check_file $t
echo "LIN_21	PERMISSIONS"
ls -l /var/log/secure
t=$_
check_file $t
echo

echo "LIN_22 - Weak permission on log files"
echo "LIN_22	MESSAGES"
ls -l /var/log/messages 2>/dev/null
t=$_
check_file $t
echo "LIN_22	WTMP"
ls -l /var/log/wtmp 2>/dev/null
t=$_
check_file $t
echo "LIN_22	XFERLOG"
ls -l /var/log/xferlog 2>/dev/null
t=$_
check_file $t
echo "LIN_22	CRON"
ls -l /var/log/cron 2>/dev/null
t=$_
check_file $t
echo "LIN_22	LASTLOG"
ls -l /var/log/lastlog 2>/dev/null
t=$_
check_file $t
echo

echo "Network settings and services"
echo "LIN_23 - Non essential services are enabled at startup"
/sbin/chkconfig --list | cut -d':' -f1,4,6,7 
echo

echo "LIN_24 - Weak network settings"
echo "LIN_24	IGNORE BROADCASTS"
/sbin/sysctl net.ipv4.icmp_echo_ignore_broadcasts
echo "LIN_24	ACCEPT REDIRECTS"
/sbin/sysctl net.ipv4.conf.all.accept_redirects
echo "LIN_24	SEND REDIRECTS"
/sbin/sysctl net.ipv4.conf.all.send_redirects
echo "LIN_24	RPFILTER"
/sbin/sysctl net.ipv4.conf.all.rp_filter
echo "LIN_24	DEFAULT RPFILTER"
/sbin/sysctl net.ipv4.conf.default.rp_filter
echo "LIN_24	IPFORWARD"
/sbin/sysctl net.ipv4.ip_forward
echo "LIN_24	ACCEPTSOURCEROUTE"
/sbin/sysctl net.ipv4.conf.all.accept_source_route
echo "LIN_24	MAXSYNBACKLOG"
/sbin/sysctl net.ipv4.tcp_max_syn_backlog
echo "LIN_24	SYNCOOKIES"
/sbin/sysctl net.ipv4.tcp_syncookies
echo "LIN_24	ERRORRESPONSES"
/sbin/sysctl net.ipv4.icmp_ignore_bogus_error_responses
echo


echo "LIN_26 - Disable All shares"
cat /etc/exports 2>/dev/null
t=$_
check_file $t
echo

echo "LIN_27 - Authentication & authorization of users against PAM"
rpm -qa | egrep -i 'pam'
echo

echo "LIN_28 - Sudo Configuration file"
cat /etc/sudoers 2>/dev/null
t=$_
check_file $t
echo

echo "LIN_29 - TCP Wrappers"
rpm -qa | egrep -i 'tcp_wrappers'
echo

echo "LIN_30- Immutable bit"
echo "Immutable bit for all the files and folders inside etc folder"
lsattr -R /etc/*
echo

rm t.txt

echo "--------------END OF OUTPUT--------------"
