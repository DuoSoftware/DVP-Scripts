#!/bin/bash
. /usr/src/params.conf

VIR_IP=$(ifconfig $VIRTUAL_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
PR_INTERFACE=$(ifconfig $PRIMARY_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')

if [ ! -z "$VIR_IP" ]
then
echo "activate this server"
else
touch $DB_TRIGER_FILE_PATH/$DB_TRIGER_FILE.$DB_PORT
sed -i 's^ACTIVE_SERVER="'$ACTIVE_SERVER'"^ACTIVE_SERVER="slave"^g' /usr/src/params.conf

#file=$DNS_CONFIG_FILE_PATH'/'$DOMAIN
#	if [ -f "$file" ]
#        then
	ifup $VIRTUAL_INTERFACE
	arping -q -c 3 -A -I $VIRTUAL_INTERFACE $PG_IP_VIRTUAL
	#fs_cli -x 'sofia recover'
	echo "Alarm $PR_INTERFACE server started"
#	else
#	echo "Alarm Failover cant start"
#	fi
fi
#PR_INTERFACE=$(ifconfig $PRIMARY_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
# echo $PR_INTERFACE
#if [ "$PR_INTERFACE" = "$FS_IP_PRIMARY" ]
#then
#    sshpass -p $PASSWORD ssh $USER_NAME@$FS_IP_SECONDRY 'service freeswitch start'
#    echo " alarm Primary Server Start on $FS_IP_SECONDRY fsTestRecovery"
#else
#    sshpass -p $PASSWORD ssh $USER_NAME@$FS_IP_PRIMARY 'service freeswitch start'
#    echo " alarm Secondry Server Crashed on $FS_IP_PRIMARY fsTestRecovery"
#fi
#if [ "$ACTIVE_SERVER" = "0" ]
#then
##ifup eth0:0
##arping -q -c 3 -A -I eth0:0 $FS_IP_VIRTUAL
#sed -i 's^ACTIVE_SERVER="0"^ACTIVE_SERVER="1"^g' params.conf
#else
#echo "activate this server"
#fi

