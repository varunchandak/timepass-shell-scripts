#!/bin/bash

echo -e "Enter path to keep the new key file:\n"
read KEY_PATH
echo -e "Enter username:\n"
read USER_NAME

ssh-keygen -f "$KEY_PATH"/"$USER_NAME" -t rsa -N ''

echo -e "The files are present in $KEY_PATH with name $USER_NAME"
echo -e "Do you want to add the key file into authorized_keys ? (Y/n)\n"
read YN_RESPONSE

while :
do
	case "$YN_RESPONSE" in
		y|Y)	echo -e "Adding the newly created keys into authorized_keys file\n"
				cp /root/.ssh/authorized_keys /root/.ssh/authorized_keys_"$(date +%s)"
				cat "$KEY_PATH"/"$USER_NAME".pub >> /root/.ssh/authorized_keys
				exit 0
				;;
		n|N)	echo -e "Add the key file manually; Do not overwrite the file."
				exit 0
				;;
		*)		echo -e "Invalid Response; such irresponsible behaviour\n"
				;;
			esac
done