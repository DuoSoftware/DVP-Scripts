#!/bin/bash
. params.conf

ChangeSlaveAsMaster () {

#SRT='slaveof '$REDIS_SERVER_MASTER' '$REDIS_PORT
#echo $SRT
##sed -i "s/$SRT/#$SRT/g" sss.cfg
#STR='s/'$SRT'/#'$SRT'/g'
#STRundo='s/#'$SRT'/'$SRT'/g'

STR_S1='tcp-keepalive 0'
STR_S1='s^'$STR_S1'^tcp-keepalive 60^g'
sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i '$STR_S1' $REDIS_CONFIG_FILE_PATH'/'$REDIS_CONFIG_FILE"

STR_S2='maxmemory-policy volatile-lru'
STR_S2_1='maxmemory-policy noeviction'
STR_S2='s/# '$STR_S2'/'$STR_S2_1'/g'
sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i '$STR_S2' $REDIS_CONFIG_FILE_PATH'/'$REDIS_CONFIG_FILE"

STR_S3='appendonly no'
STR_S3_1='appendonly yes'
STR_S3='s/'$STR_S3'/'$STR_S3_1'/g'
sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i '$STR_S3' $REDIS_CONFIG_FILE_PATH'/'$REDIS_CONFIG_FILE"

STR_S4='appendfilename appendonly.aof'
STR_S4_1='appendfilename redis-staging-ao.aof'
STR_S4='s/# '$STR_S4'/'$STR_S4_1'/g'
sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i '$STR_S4' $REDIS_CONFIG_FILE_PATH'/'$REDIS_CONFIG_FILE"


STR_S5='slaveof '$REDIS_SERVER_MASTER $REDIS_PORT
#STR_S5_1='appendfilename redis-staging-ao.aof'
STR_S5='s/'$STR_S5'/# '$STR_S5'/g'
sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i '$STR_S5' $REDIS_CONFIG_FILE_PATH'/'$REDIS_CONFIG_FILE"

STR_S6='masterauth '$PASSWORD
STR_S6='s/'$STR_S6'/# '$STR_S6'/g'
sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE "sed -i '$STR_S6' $REDIS_CONFIG_FILE_PATH'/'$REDIS_CONFIG_FILE"
#STR='tcp-keepalive 60'
#STR='s/'$STR'/#'$STR'/g'

#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_MASTER "sed -i '$STR' /usr/src/AAA.cfg"
#sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_MASTER "sed -i '$STR' $REDIS_CONFIG_FILE_PATH'/'$REDIS_CONFIG_FILE"

#CMD=$(sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE 'service '$REDIS_SERVICE' restart')
#RTNVAL=$(sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE 'service '$REDIS_SERVICE' status')
read -a TOKENS <<< "${RTNVAL}"
LAST_PART=${TOKENS[${#TOKENS[@]} - 2]}
#       sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_MASTER 'touch '$DB_TRIGER_FILE_PATH'/'$DB_TRIGER_FILE.$DB_PORT
#>>>>>>note online should change to down
if [ "$LAST_PART" = "not" ]
then
return 0;
else
return 1;
fi


}

UpdateDNS () {

        file=$DNS_CONFIG_FILE_PATH'/'$DOMAIN
#       echo $file
        if [ -f "$file" ]
        then
        echo " file Found"
        sed -i 's^'$REDIS_DNS_NAME'.\tIN\tA\t'$REDIS_SERVER_MASTER'^'$REDIS_DNS_NAME'.\tIN\tA\t'$REDIS_SERVER_SLAVE'^g' $file
        sed -i 's^REDIS_SERVER_MASTER="'$REDIS_SERVER_MASTER'"^REDIS_SERVER_MASTER="'$REDIS_SERVER_SLAVE'"^g' params.conf
        sed -i 's^REDIS_SERVER_SLAVE="'$REDIS_SERVER_SLAVE'"^REDIS_SERVER_SLAVE="'$REDIS_SERVER_MASTER'"^g' params.conf

        service bind9 reload
        CMD=$(service bind9 status)
        read -a TOKENS <<< "${CMD}"
        LAST_PART=${TOKENS[${#TOKENS[@]} - 1]}

                if [ "$LAST_PART" = "running" ]
                then
                #Alarm service webmin up change master to slave
#                $var="Alarm service webmin up change master to slave"
               echo "Alarm service webmin up change master to slave"
                else
                #Alarm Error Totaly down
 #              echo "Alarm Error Totaly down"
                sed -i 's^'$REDIS_DNS_NAME'.\tIN\tA\t'$REDIS_SERVER_SLAVE'^'$REDIS_DNS_NAME'.\tIN\tA\t'$REDIS_SERVER_MASTER'^g' $file
                sed -i 's^REDIS_SERVER_MASTER="'$REDIS_SERVER_SLAVE'"^REDIS_SERVER_MASTER="'$REDIS_SERVER_MASTER'"^g' params.conf
                sed -i 's^REDIS_SERVER_SLAVE="'$REDIS_SERVER_MASTER'"^REDIS_SERVER_SLAVE="'$REDIS_SERVER_SLAVE'"^g' params.conf
                fi
        else
#        var="not found."
       echo "$file not found."
        #alarm
        fi


}

ServiceStatusSlave () {

 RTNVAL=$(sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE 'service '$REDIS_SERVICE' status')
        #RESULTS=$(ssh user@server /usr/local/scripts/test_ping.sh)
        #echo $RESULT
        read -a TOKENS <<< "${RTNVAL}"
        LAST_PART=${TOKENS[${#TOKENS[@]} - 2]}
 #       echo $LAST_PART

                if [ "$LAST_PART" = "not" ]

                then
                #CMD=$(sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE 'service '$REDIS_SERVICE' start')
                #RTNVAL=$(sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_SLAVE 'service '$REDIS_SERVICE' status')
                read -a TOKENS <<< "${RTNVAL}"
                LAST_PART=${TOKENS[${#TOKENS[@]} - 2]}
        #       sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_MASTER 'touch '$DB_TRIGER_FILE_PATH'/'$DB_TRIGER_FILE.$DB_PORT

                #>>>>>>note online should change to down
                        if [ "$LAST_PART" = "not" ]

                        then
			return 0;
			else
			return 1;
			fi
		else
                return 1;
		fi

}


ServiceStatusMaster () {

 RTNVAL=$(sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_MASTER 'service '$REDIS_SERVICE' status')
        #RESULTS=$(ssh user@server /usr/local/scripts/test_ping.sh)
        #echo $RESULT
        read -a TOKENS <<< "${RTNVAL}"
        LAST_PART=${TOKENS[${#TOKENS[@]} - 2]}
      #  echo $LAST_PART


                if [ "$LAST_PART" = "not" ]
                then
               # CMD=$(sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_MASTER 'service '$REDIS_SERVICE' start')
                #RTNVAL=$(sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_SERVER_MASTER 'service '$REDIS_SERVICE' status')
                read -a TOKENS <<< "${RTNVAL}"
                LAST_PART=${TOKENS[${#TOKENS[@]} - 2]}
        #       sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_MASTER 'touch '$DB_TRIGER_FILE_PATH'/'$DB_TRIGER_FILE.$DB_PORT

                #>>>>>>note online should change to down

                        if [ "$LAST_PART" = "not" ]
                        then
                        return 0;
                        else
                        return 1;
                        fi
                else
		return 1;
		fi

}

ServerStatusMaster1 () {

CON=$(nc -z -v -w5 $DB_SERVER_MASTER 22)
echo $CON
}


ServerStatusMaster () {

CON=$(nc -z -v -w5 $REDIS_SERVER_MASTER 22 2>&1)
read -a CONSTATUS <<< "${CON}"
LAST_PART=${CONSTATUS[${#CONSTATUS[@]} - 1]}
if [ "$LAST_PART" = "refused" ]
then
sleep 10

CON2=$(nc -z -v -w5 $REDIS_SERVER_MASTER 22 2>&1)
read -a CONSTATUS2 <<< "${CON2}"
LAST_PART=${CONSTATUS2[${#CONSTATUS2[@]} - 1]}

        if [ "$LAST_PART" = "refused" ]
        then
        #echo "Connectivity failed"
	return 0;
	else
	return 1;
	fi
else
return 1;

fi
}


ServerStatusSlave () {

CON=$(nc -z -v -w5 $REDIS_SERVER_SLAVE 22 2>&1)
read -a CONSTATUS <<< "${CON}"
LAST_PART=${CONSTATUS[${#CONSTATUS[@]} - 1]}
if [ "$LAST_PART" = "refused" ]
then
sleep 10

CON2=$(nc -z -v -w5 $REDIS_SERVER_SLAVE 22 2>&1)
read -a CONSTATUS2 <<< "${CON2}"
LAST_PART=${CONSTATUS2[${#CONSTATUS2[@]} - 1]}

        if [ "$LAST_PART" = "refused" ]
        then
        #echo "Connectivity failed"
        return 0;
        else
        return 1;
        fi
else
return 1;
fi

}


#ChangeSlaveAsMaster
#ServiceStatusSlave
#ServiceStatusMaster
#masterStatusVal=$?i
#ServerStatusSlave
#ServerStatusMaster
#echo $?

ServerStatusMaster
#ServiceStatusMaster
masterStatusVal=$?
if [ "$masterStatusVal" = "1" ]
then
ServiceStatusMaster
masterServiceDB=$?
echo $masterServiceRedis
	if [ "$masterServiceRedis" = "1" ]
	then
	echo " master Redis Working_1"
	#working Properly
	else
	#failover start
	ServerStatusSlave
	#ServiceStatusMaster
	slaveStatusVal=$?
		if [ "$slaveStatusVal" = "1" ]
		then
		ServiceStatusSlave
		slaveServiceRedis=$?
		echo $slaveServiceRedis
		        if [ "$slaveServiceRedis" = "1" ]
		        then
			#alarm
		        #failover start
			ChangeSlaveAsMaster
			serviceRedisReload=$?
				if [ "$serviceRedisReload" = "1" ]
				then
				UpdateDNS
				else
				echo "Alarm Slave Redis Can't Restart"
				fi
			else
			echo "alarm Slave DB down_1"			
			fi
		else
		echo "alarm Slave server down_2"
		fi
	fi
else
#Alarm
#failover start
echo "else"
ServerStatusSlave
#ServiceStatusMaster
slaveStatusVal=$?
	if [ "$slaveStatusVal" = "1" ]
	then
	ServiceStatusSlave
	slaveServiceRedis=$?
	echo $slaveServiceRedis
		if [ "$slaveServiceRedis" = "1" ]
	        then
	        #alarm
		#failover start
	        ChangeSlaveAsMaster
                serviceRedisReload=$?
	                if [ "$serviceRedisReload" = "1" ]
                        then
                        UpdateDNS
                        else
                        echo "Alarm Slave Redis Can't Restart"
                        fi

        	else
	        echo "alarm Slave DB down_3"
		fi
	else
	echo "alarm Slave server down_4"
	fi

fi
#echo $masterStatusVal;

#CON=$(sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_MASTER 'service '$DB_SERVICE' status')
#CON=$(nc -z -v -w5 $DB_SERVER_MASTER 22  2>&1)
#read -a CONSTATUS <<< "${CON}"
#LAST_PART=${CONSTATUS[${#CONSTATUS[@]}]}

#echo "${CON}"..

#ping_results=$(ping -c 4 -q google.com 2>&1);

#echo "asasa" $ping_results
###

