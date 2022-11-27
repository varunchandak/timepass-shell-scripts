#!/bin/bash

YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)

encryptEphemeral() {
	for i in sha256 dm_crypt xfs; do
		sudo modprobe $i
		echo $i | sudo tee -a /etc/modules
	done
	sudo umount /media/ephemeral0
	sudo chmod 000 /media/ephemeral0
	
	# Enter a passphrase below (the key file will be removed later):
	echo "Cl0ud#9090" > /root/keyfile.pem
	cryptsetup luksFormat /dev/xvdb < /root/keyfile.pem
	cryptsetup luksOpen /dev/xvdb my_enc_fs < /root/keyfile.pem
	rm -f /root/keyfile.pem
	mkfs.ext4 -m 0 /dev/mapper/my_enc_fs
	mkdir /encrypted_vol
	mount -vvv /dev/mapper/my_enc_fs /encrypted_vol > /tmp/mount-logs.log 2>&1
	cryptsetup status my_enc_fs >> /tmp/mount-logs.log
}

if [[ ! -z $YUM_CMD ]]; then
	yum install -y cryptsetup xfsprogs
	encryptEphemeral
elif [[ ! -z $APT_GET_CMD ]]; then
	apt-get update; apt-get install -y cryptsetup xfsprogs
	encryptEphemeral
else
    echo "error can't install package $PACKAGE"
    exit 1;
fi