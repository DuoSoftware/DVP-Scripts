#!/bin/bash
. /usr/src/RedisHA/params.conf

ChangeSlaveAsMaster () {

#STR_S1='tcp-keepalive 0'
#STR_S1='s^'$STR_S1'^tcp-keepalive 60^g'
#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i '$STR_S1' $REDIS_CONFIG_FILE_PATH'/'$REDIS_CONFIG_FILE"

STR_S1='tcp-keepalive 0'
STR_S1='s^'$STR_S1'^tcp-keepalive 60^g'
#####echo $STR_S2
#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_IP_SLAVE "sed -i "$STR_S2" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
sed -i "$STR_S1" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE

STR_S2='maxmemory-policy volatile-lru'
STR_S2_1='maxmemory-policy noeviction'
STR_S2='s/# '$STR_S2'/'$STR_S2_1'/g'

#echo $STR_S2
#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_iIP_SLAVE "sed -i "$STR_S2" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
sed -i "$STR_S2" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE

STR_S3='appendonly no'
STR_S3_1='appendonly yes'
STR_S3='s/'$STR_S3'/'$STR_S3_1'/g'
#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_IP_SLAVE "sed -i "$STR_S3" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
sed -i "$STR_S3" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE

STR_S4='appendfilename appendonly.aof'
STR_S4_1='appendfilename redis-staging-ao.aof'
STR_S4='s/'$STR_S4'/'$STR_S4_1'/g'
#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_IP_SLAVE "sed -i "$STR_S4" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
sed -i "$STR_S4" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE

STR_S5='slaveof '"$REDIS_IP_VIRTUAL $REDIS_PORT"
#echo $STR_S5
STR_S5='s/'$STR_S5'/# '$STR_S5'/g'
#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS__SLAVE "sed -i "$STR_S5" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
sed -i "$STR_S5" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE



STR_S6='masterauth '$PASSWORD
STR_S6='s/'$STR_S6'/# '$STR_S6'/g'
#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i "$STR_S6" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
sed -i "$STR_S6" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE

STR_S7='slave-read-only yes'
STR_S7='s/'$STR_S7'/# '$STR_S7'/g'
#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i "$STR_S6" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
sed -i "$STR_S7" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE


}

VIR_IP=$(ifconfig $VIRTUAL_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
PR_INTERFACE=$(ifconfig $PRIMARY_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')

if [ ! -z "$VIR_IP" ]
then
echo "activate this server"
else

ChangeSlaveAsMaster
#touch $DB_TRIGER_FILE_PATH/$DB_TRIGER_FILE.$DB_PORT
CMD=$(service $REDIS_SERVICE restart)
RTNVAL=$(service $REDIS_SERVICE status)
read -a TOKENS <<< "${RTNVAL}"
LAST_PART=${TOKENS[${#TOKENS[@]} - 2]}
#       sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_MASTER 'touch '$DB_TRIGER_FILE_PATH'/'$DB_TRIGER_FILE.$DB_PORT
#>>>>>>note online should change to down
if [ "$LAST_PART" = "not" ]
then
echo "Alarm $PR_INTERFACE server Cannot Start.."
else
sed -i 's^ACTIVE_SERVER="'$ACTIVE_SERVER'"^ACTIVE_SERVER="slave"^g' /usr/src/RedisHA/params.conf

#file=$DNS_CONFIG_FILE_PATH'/'$DOMAIN
#	if [ -f "$file" ]
#        then
	ifup $VIRTUAL_INTERFACE
	arping -q -c 3 -A -I $VIRTUAL_INTERFACE $REDIS_IP_VIRTUAL
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
fi
