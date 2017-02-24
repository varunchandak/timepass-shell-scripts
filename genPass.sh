#!/bin/bash

# This script will:
# 	- generate complex passwords with x character limit
#	- generate a list of n passwords
# To change the character limit, change the CHAR_LIMIT variable
# To change the number of passwords generated, change the PASS_COUNT variable

CHAR_LIMIT=20
PASS_COUNT=20

for i in `seq $PASS_COUNT`
	do cat /dev/urandom| tr -dc 'a-zA-Z0-9-_@#^'|fold -w "$CHAR_LIMIT" | head -n 1
done
