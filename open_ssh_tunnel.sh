#!/bin/bash

echo "Opening Tunnel on Port 9999"
echo "Enter the Server's IP Address whom you want to SSH"
#read IP

ssh -D 9999 -C -N $1

