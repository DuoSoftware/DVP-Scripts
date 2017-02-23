#!/bin/bash
. params.conf

#RTNVAL=$(sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE 'service '$REDIS_SERVICE' status')
#REDIS_PORT="6379"

#SLAVE CHANGES
#sed -e '/BBB/ s/^#*/#/' -i file
SRT='slaveof '$REDIS_SERVER_MASTER' '$REDIS_PORT
echo $SRT
#sed -i "s/$SRT/#$SRT/g" sss.cfg 
STR='s/'$SRT'/#'$SRT'/g'
STRundo='s/#'$SRT'/'$SRT'/g'
#echo $STR
#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE 'sed -i "$STR"' /usr/src/sss.cfg

#sed -i '/slaveof '$REDIS_SERVER_MASTER $REDIS_PORT'/s/^/#/' sss.cfg
#sed -e '/{$SRT}/ s/^#*/#/' -i sss.cfg
#sed -i '/'$SRT'/s/^/#/' sss.cfg
#sed -i '/slaveof 192.168.2.181 6379/s/^/#/' sss.cfg
#-STR='/slaveof '$REDIS_SERVER_MASTER $REDIS_PORT'/ s/^#*/#/'
#BIND_SLAVEOF='s^slaveof '$REDIS_SERVER_MASTER $REDIS_PORT'^# slaveof '$REDIS_SERVER_MASTER $REDIS_PORT'^g'
#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i '$BIND_SLAVEOF $REDIS_CONFIG_FILE_PATH'/redis.cfg"
#--sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -e '$STR' -i /usr/src/redis.cfg"
#sed -i '/ 2001 /s/^/#/' sss.cfg 
#STR='s^REDIS_PORT=6379^REDIS_PORT=1111^g'

#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_MASTER "sed -i '$STR' /usr/src/AAA.cfg"
STR_S5='slaveof '$REDIS_SERVER_MASTER $REDIS_PORT
echo $STR_S5
#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_MASTER "sed -i '$STRundo' /usr/src/AAA.cfg"

#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_MASTER 'mv /usr/src/BBB.cfg /usr/src/AAA.cfg'
        #RESULTS=$(ssh user@server /usr/local/scripts/test_ping.sh)
#sed -i $STR /usr/src/AAA.cfg
#sed -i 's^REDIS_PORT="6379"^REDIS_PORT="1111"^g' /usr/src/AAA.cfg
#        echo $RTNVAL
#        read -a TOKENS <<< "${RTNVAL}"
#        LAST_PART=${TOKENS[${#TOKENS[@]} - 2]}
#      #  echo $LAST_PART.
#	if [ "$LAST_PART" = "not" ]
#
#                then
#echo "$LAST_PART"
#fi
