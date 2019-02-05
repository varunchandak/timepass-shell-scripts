#!/bin/bash

# The below is run as root user (or sudo user) and tested on Ubuntu Machine

# Create a User with restricted bash shell
useradd -s /bin/rbash -m "$USERNAME"
mkdir /home/"$USERNAME"/.ssh/

# Copy the pubkeys here and change permissions
cd /home/"$USERNAME"/
cat /tmp/"$PUBLIC_KEY" >> .ssh/authorized_keys
chmod 0700 .ssh/
chown -R "$USERNAME":"$USERNAME" .ssh

# remove temp keys
# Add command symlinks to the user private bin dir
cd /home/"$USERNAME"
mkdir bin

ln -s /bin/ls /home/"$USERNAME"/bin/
ln -s /usr/bin/top /home/"$USERNAME"/bin/
ln -s /usr/bin/du /home/"$USERNAME"/bin/
ln -s /bin/date /home/"$USERNAME"/bin/
ln -s /bin/uname /home/"$USERNAME"/bin/
ln -s /usr/bin/free /home/"$USERNAME"/bin/
ln -s /usr/bin/head /home/"$USERNAME"/bin/
ln -s /usr/bin/tail /home/"$USERNAME"/bin/
ln -s /usr/bin/less /home/"$USERNAME"/bin/
ln -s /bin/more /home/"$USERNAME"/bin/
ln -s /bin/cat /home/"$USERNAME"/bin/
ln -s /bin/ping /home/"$USERNAME"/bin/
ln -s /usr/bin/telnet /home/"$USERNAME"/bin/

# Update path and deny path editing for "$USERNAME"
cd /home/"$USERNAME"
sed -i '/^PATH/s/PATH.*/PATH=\$HOME\/bin/g' .profile
sed -i '/^PATH/s/PATH.*/PATH=\$HOME\/bin/g' .bashrc
chattr +i .bashrc .profile
