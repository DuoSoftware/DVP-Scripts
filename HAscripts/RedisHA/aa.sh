#!/bin/bash
. params.conf

#STR_S5='slaveof '"$REDIS_IP_PRIMARY $REDIS_PORT"
#
#echo $STR_S5
#STR_S5='s/'$STR_S5'/# '$STR_S5'/g'
##sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i "$STR_S5" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE"
#sed -i "$STR_S5" $REDIS_CONFIG_FILE_PATH/$REDIS_CONFIG_FILE
#i

CMD=$(service $REDIS_SERVICE stop)
