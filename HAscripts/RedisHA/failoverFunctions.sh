#!/bin/bash
. params.conf

CreateTrigerAndUpdateDNS () {

	sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_MASTER 'touch '$DB_TRIGER_FILE_PATH'/'$DB_TRIGER_FILE.$DB_PORT
	file=$DNS_CONFIG_FILE_PATH'/'$DOMAIN.hosts
#	echo $file
	if [ -f "$file" ]
	then
	echo " file Found"
	sed -i 's^pgsql.db1.poc.lk.\tIN\tA\t'$DB_SERVER_MASTER'^pgsql.db1.poc.lk.\tIN\tA\t'$DB_SERVER_SLAVE'^g' $file
	sed -i 's^DB_SERVER_MASTER="'$DB_SERVER_MASTER'"^DB_SERVER_MASTER="'$DB_SERVER_SLAVE'"^g' params.conf
	sed -i 's^DB_SERVER_SLAVE="'$DB_SERVER_SLAVE'"^DB_SERVER_SLAVE="'$DB_SERVER_MASTER'"^g' params.conf

	service bind9 reload
	CMD=$(service bind9 status)
	read -a TOKENS <<< "${CMD}"
	LAST_PART=${TOKENS[${#TOKENS[@]} - 1]}

		if [ "$LAST_PART" = "running" ]
	        then
        	#Alarm service webmin up change master to slave
		$var="Alarm service webmin up change master to slave"
#	        echo "Alarm service webmin up change master to slave"
        	else
	        #Alarm Error Totaly down
 #       	echo "Alarm Error Totaly down"
	        sed -i 's^pgsql.db1.poc.lk.\tIN\tA\t'$DB_SERVER_SLAVE'^pgsql.db1.poc.lk.\tIN\tA\t'$DB_SERVER_MASTER'^g' $file
        	sed -i 's^DB_SERVER_MASTER="'$DB_SERVER_SLAVE'"^DB_SERVER_MASTER="'$DB_SERVER_MASTER'"^g' params.conf
	        sed -i 's^DB_SERVER_SLAVE="'$DB_SERVER_MASTER'"^DB_SERVER_SLAVE="'$DB_SERVER_SLAVE'"^g' params.conf
        	fi
	else
	var="not found."
	echo "$file not found."
	#alarm
	fi

}


ServiceStatusSlave () {

 RTNVAL=$(sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_SLAVE 'service '$DB_SERVICE' status')
        #RESULTS=$(ssh user@server /usr/local/scripts/test_ping.sh)
        #echo $RESULT
        read -a TOKENS <<< "${RTNVAL}"
        LAST_PART=${TOKENS[${#TOKENS[@]} - 1]}
 #       echo $LAST_PART

                if [ "$LAST_PART" = "down,recovery" ]

                then
                CMD=$(sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_SLAVE 'service '$DB_SERVICE' start')
                RTNVAL=$(sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_SLAVE 'service '$DB_SERVICE' status')
                read -a TOKENS <<< "${RTNVAL}"
                LAST_PART=${TOKENS[${#TOKENS[@]} - 1]}
        #       sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_MASTER 'touch '$DB_TRIGER_FILE_PATH'/'$DB_TRIGER_FILE.$DB_PORT

                #>>>>>>note online should change to down
                        if [ "$LAST_PART" = "online,recovery" ]

                        then
			return 0;
			else
			return 1;
			fi
		fi

}


ServiceStatusMaster () {

 RTNVAL=$(sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_MASTER 'service '$DB_SERVICE' status')
        #RESULTS=$(ssh user@server /usr/local/scripts/test_ping.sh)
        #echo $RESULT
        read -a TOKENS <<< "${RTNVAL}"
        LAST_PART=${TOKENS[${#TOKENS[@]} - 1]}
      #  echo $LAST_PART


                if [ "$LAST_PART" = "down" ]
                then
                CMD=$(sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_MASTER 'service '$DB_SERVICE' start')
                RTNVAL=$(sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_MASTER 'service '$DB_SERVICE' status')
                read -a TOKENS <<< "${RTNVAL}"
                LAST_PART=${TOKENS[${#TOKENS[@]} - 1]}
        #       sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_MASTER 'touch '$DB_TRIGER_FILE_PATH'/'$DB_TRIGER_FILE.$DB_PORT

                #>>>>>>note online should change to down

                        if [ "$LAST_PART" = "down" ]
                        then
                        return 0;
                        else
                        return 1;
                        fi
                else
		return 2;
		fi

}

ServerStatusMaster1 () {

CON=$(nc -z -v -w5 $DB_SERVER_MASTER 22)
echo $CON
}


ServerStatusMaster () {

CON=$(nc -z -v -w5 $DB_SERVER_MASTER 22 2>&1)
read -a CONSTATUS <<< "${CON}"
LAST_PART=${CONSTATUS[${#CONSTATUS[@]} - 1]}
if [ "$LAST_PART" = "refused" ]
then
sleep 10

CON2=$(nc -z -v -w5 $DB_SERVER_MASTER 22 2>&1)
read -a CONSTATUS2 <<< "${CON2}"
LAST_PART=${CONSTATUS2[${#CONSTATUS2[@]} - 1]}

        if [ "$LAST_PART" = "refused" ]
        then
        echo "Connectivity failed"
	return 0;
	else
	return 1;
	fi
else
return 1;

fi
}


ServerStatusSlave () {

CON=$(nc -z -v -w5 $DB_SERVER_SLAVE 22 2>&1)
read -a CONSTATUS <<< "${CON}"
LAST_PART=${CONSTATUS[${#CONSTATUS[@]} - 1]}
if [ "$LAST_PART" = "refused" ]
then
sleep 10

CON2=$(nc -z -v -w5 $DB_SERVER_SLAVE 22 2>&1)
read -a CONSTATUS2 <<< "${CON2}"
LAST_PART=${CONSTATUS2[${#CONSTATUS2[@]} - 1]}

        if [ "$LAST_PART" = "refused" ]
        then
        echo "Connectivity failed"
        return 0;
        else
        return 1;
        fi
else
return 1;
fi

}




ServerStatusMaster
#ServiceStatusMaster
masterStatusVal=$?
if [ "$masterStatusVal" = "1" ]
then
ServiceStatusMaster
masterServiceDB=$?
echo $masterServiceDB
	if [ "masterServiceDB" = "1" ]
	then
	echo "masterServiceDB 1"
	#working Properly
	else
	#failover start
	ServerStatusSlave
	#ServiceStatusMaster
	slaveStatusVal=$?
		if [ "$slaveStatusVal" = "1" ]
		then
		ServiceStatusSlave
		slaveServiceDB=$?
		echo $slaveServiceDB
		        if [ "slaveServiceDB" = "1" ]
		        then
			#alarm
			echo "slaveservicedb 1"
		        #failover start
			CreateTrigerAndUpdateDNS
			else
			#alarm Slave DB down
			echo "slaveservicedb 2"			
			fi
		else
		#alarm Slave server down
		echo "else 202"
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
	slaveServiceDB=$?
	echo $slaveServiceDB
		if [ "slaveServiceDB" = "1" ]
	        then
	        #alarm
		#failover start
	        CreateTrigerAndUpdateDNS
        	else
		echo "else 222"
	        #alarm Slave DB down
		fi
	else
	#alarm Slave server down
        echo "else 227"
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

