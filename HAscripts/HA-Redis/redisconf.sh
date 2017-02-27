#!/bin/bash
. /usr/src/RedisHA/params.conf

#####echo $REDIS_CONFIG_FILE_PATH
STR_S1='tcp-keepalive 0'
STR_S2='s^'$STR_S1'^tcp-keepalive 60^g'
#####echo $STR_S2
sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i "$STR_S2" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
#####echo " -i $STR_S2 $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
#sed -i "$STR_S2" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE


STR_S2='maxmemory-policy volatile-lru'
STR_S2_1='maxmemory-policy noeviction'
STR_S2='s/# '$STR_S2'/'$STR_S2_1'/g'

#echo $STR_S2
sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i "$STR_S2" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
#sed -i "$STR_S2" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE


STR_S3='appendonly no'
STR_S3_1='appendonly yes'
STR_S3='s/'$STR_S3'/'$STR_S3_1'/g'
sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i "$STR_S3" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
#sed -i "$STR_S3" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE


STR_S4='appendfilename appendonly.aof'
STR_S4_1='appendfilename redis-staging-ao.aof'
STR_S4='s/# '$STR_S4'/'$STR_S4_1'/g'
sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i "$STR_S4" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
#sed -i "$STR_S4" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE


STR_S5='slaveof '"$REDIS_IP_PRIMARY $REDIS_PORT"
echo $STR_S5
STR_S5='s/'$STR_S5'/# '$STR_S5'/g'
sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i "$STR_S5" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
#sed -i "$STR_S5" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE



STR_S6='masterauth '$PASSWORD
STR_S6='s/'$STR_S6'/# '$STR_S6'/g'
sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i "$STR_S6" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
#sed -i "$STR_S6" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE







