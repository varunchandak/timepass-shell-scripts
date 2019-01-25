#!/bin/bash

echo "Enter Username: (without spaces)"
read USRNAME
echo "Enter Password for $USRNAME:"
read -s PASSWD
echo "Please wait while adding sudo user:"
useradd "$USRNAME" -g gpadmin; echo -e "$PASSWD\n$PASSWD" | (passwd --stdin "$USRNAME") > /dev/null
echo "User $USRNAME has been successfully added in sudo users list"
