#!/bin/sh

export PATH=/bin:/usr/bin

##########################################################################
#                                                                        #
#  This program is free software: you can redistribute it and/or modify  #
#  it under the terms of the GNU General Public License as published by  #
#  the Free Software Foundation, either version 3 of the License, or     #
#  (at your option) any later version.                                   #
#                                                                        #
#  This program is distributed in the hope that it will be useful,       #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#  GNU General Public License for more details.                          #
#                                                                        #
#  You should have received a copy of the GNU General Public License     #
#  along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#                                                                        #
##########################################################################


###############################################################################
# START USER CONFIGURABLE VARIABLES
###############################################################################

EMAIL="email@domain.com"

# 1 minute load avg
MAX_LOAD=3

# kB
MAX_SWAP_USED=1000

# kB
MAX_MEM_USED=500000

# packets per second inbound
MAX_PPS_IN=2000

# packets per second outbound
MAX_PPS_OUT=2000

# max processes in the process list
MAX_PROCS=400

###############################################################################
# END USER CONFIGURABLE VARIABLES
###############################################################################


IFACE=`grep ETHDEV /etc/wwwacct.conf | awk '{print $2}'`
if [[ "$IFACE" =~ "venet" ]] ; then
    IFACE=venet0
fi

IFACE=${IFACE}:

###############################################################################
# 1 min load avg
###############################################################################
ONE_MIN_LOADAVG=`cut -d . -f 1 /proc/loadavg`
echo "1 minute load avg: $ONE_MIN_LOADAVG"


###############################################################################
# swap used
###############################################################################
SWAP_TOTAL=`grep ^SwapTotal: /proc/meminfo | awk '{print $2}'`
SWAP_FREE=`grep ^SwapFree: /proc/meminfo | awk '{print $2}'`

let "SWAP_USED = (SWAP_TOTAL - SWAP_FREE)"
echo "Swap used: $SWAP_USED kB"


###############################################################################
# mem used
###############################################################################
MEM_TOTAL=`grep ^MemTotal: /proc/meminfo | awk '{print $2}'`
MEM_FREE=`grep ^MemFree: /proc/meminfo | awk '{print $2}'`

let "MEM_USED = (MEM_TOTAL - MEM_FREE)"
echo "Mem used: $MEM_USED kB"


###############################################################################
# packets received
###############################################################################
PACKETS_RX_1=`grep $IFACE /proc/net/dev | awk '{print $2}'`
sleep 2;
PACKETS_RX_2=`grep $IFACE /proc/net/dev | awk '{print $2}'`

let "PACKETS_RX = (PACKETS_RX_2 - PACKETS_RX_1) / 2"
echo "packets received (2 secs): $PACKETS_RX"


###############################################################################
# packets sent
###############################################################################
PACKETS_TX_1=`grep $IFACE /proc/net/dev | awk '{print $10}'`
sleep 2;
PACKETS_TX_2=`grep $IFACE /proc/net/dev | awk '{print $10}'`

let "PACKETS_TX = (PACKETS_TX_2 - PACKETS_TX_1) / 2"
echo "packets sent (2 secs): $PACKETS_TX"

let "SWAP_USED = SWAP_TOTAL - SWAP_FREE"
if [ ! "$SWAP_USED" == 0 ] ; then
    PERCENTAGE_SWAP_USED=`echo $SWAP_USED / $SWAP_TOTAL | bc -l`
    TOTAL_PERCENTAGE=`echo ${PERCENTAGE_SWAP_USED:1:2}%`
else
    TOTAL_PERCENTAGE='0%'
fi


###############################################################################
# number of processes
###############################################################################
MAX_PROCS_CHECK=`ps ax | wc -l`

send_alert()
{
    SUBJECTLINE="`hostname` [L: $ONE_MIN_LOADAVG] [P: $MAX_PROCS_CHECK] [Swap Use: $TOTAL_PERCENTAGE ] [pps in: $PACKETS_RX  pps out: $PACKETS_TX]"
    ps auxwwwf | mail -s "$SUBJECTLINE" $EMAIL
    exit
}


if   [ $ONE_MIN_LOADAVG -gt $MAX_LOAD      ] ; then send_alert
elif [ $SWAP_USED       -gt $MAX_SWAP_USED ] ; then send_alert
elif [ $MEM_USED        -gt $MAX_MEM_USED  ] ; then send_alert
elif [ $PACKETS_RX      -gt $MAX_PPS_IN    ] ; then send_alert
elif [ $PACKETS_TX      -gt $MAX_PPS_OUT   ] ; then send_alert
elif [ $MAX_PROCS_CHECK -gt $MAX_PROCS ] ; then send_alert
fi
