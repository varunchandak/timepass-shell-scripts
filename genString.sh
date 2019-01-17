#!/bin/bash

# This script is used to insert periods (dots, .) between a string.
# This script is originally intended to generate aliases for Gmail Users (Tutorial Here: https://www.cloudbeings.in/2017/01/20/generate-thousands-of-email-addresses-using-your-own-email-address/)
#
# The script takes 1 input as a simple string
#
# Example:
# ./string_generator.sh random
#
# Original Question asked on SO: https://bit.ly/2RAujRo

# Output:
# ---- one dot ----
# r.andom
# ra.ndom
# ran.dom
# rand.om
# rando.m
# ---- two dots ----
# r.a.ndom
# r.an.dom
# r.and.om
# r.ando.m
# ra.n.dom
# ra.nd.om
# ra.ndo.m
# ran.d.om
# ran.do.m
# rand.o.m
# ---- three dots ----
# r.a.n.dom
# r.a.nd.om
# r.a.ndo.m
# r.an.d.om
# r.an.do.m
# r.and.o.m
# ra.n.d.om
# ra.n.do.m
# ra.nd.o.m
# ran.d.o.m

t=$1

echo '---- one dot ----'

for (( i = 1; i < ${#t}; ++i )); do
    echo "${t:0:i}.${t:i}"
done

echo '---- two dots ----'

for (( i = 1; i < (${#t} - 1); ++i )); do
    for (( j = i + 1; j < ${#t}; ++j )); do
        echo "${t:0:i}.${t:i:j - i}.${t:j}"
    done
done


echo '---- three dots ----'

for (( i = 1; i < (${#t} - 1); ++i )); do
    for (( j = i + 1; j < ${#t}; ++j )); do
    	for (( k = j + 1; k < ${#t}; ++k )); do
        echo "${t:0:i}.${t:i:j - i}.${t:j:k - j}.${t:k}"
	done
    done
done
