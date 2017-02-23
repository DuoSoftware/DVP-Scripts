#!/bin/bash
. params.conf

#PID=$(pidof freeswitch)
#echo $PID
#VIR_IP=$(ifconfig $VIRTUAL_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
#echo $VIR_IP
#
#if [ "$VIR_IP" = "$FS_IP_VIRTUAL" ]
#then
#sleepTime="1"
#else
#sleepTime="15"
#fi

CheckServerCon () {

	CON=$(nc -z -v -w5 $PG_IP_VIRTUAL 22 2>&1)
#	read -a CONSTATUS <<< "${CON}"
#	LAST_PART=${CONSTATUS[${#CONSTATUS[@]} - 1]}
        LAST_PART=${CON[${#CON[@]} - 1]}
        LAST_PART=${LAST_PART##* }
	
	if [ "$LAST_PART" = "out" ]
	then
		return 0;
	else
		return 1;
	fi

}

ServerStatus () {

CON=$(nc -z -v -w5 $PG_IP_VIRTUAL 22 2>&1)
read -a CONSTATUS <<< "${CON}"
LAST_PART=${CONSTATUS[${#CONSTATUS[@]} - 1]}
if [ "$LAST_PART" = "succeeded!" ] || [ "$LAST_PART" = "open" ]
then
return 1;
else
sleep 5

CON2=$(nc -z -v -w5 $PG_IP_VIRTUAL 22 2>&1)
read -a CONSTATUS2 <<< "${CON2}"
LAST_PART=${CONSTATUS2[${#CONSTATUS2[@]} - 1]}

        if [ "$LAST_PART" = "succeeded!" ] || [ "$LAST_PART" = "open" ]
        then
        #echo "Connectivity Sucess"
        return 1;
        else
        return 0;
	#echo "Connectivity Failed"
        fi
fi
}



ServiceStatus () {

 RTNVAL=$(service $DB_SERVICE status)
        #RESULTS=$(ssh user@server /usr/local/scripts/test_ping.sh)
        #echo $RESULT
        read -a TOKENS <<< "${RTNVAL}"
        LAST_PART=${TOKENS[${#TOKENS[@]} - 1]}
 #       echo $LAST_PART

                if [ "$LAST_PART" = "down,recovery" ] || [ "$LAST_PART" = "down" ]

                then
#                CMD=$(service $DB_SERVICE start)
                RTNVAL=$(service $DB_SERVICE status)
                read -a TOKENS <<< "${RTNVAL}"
                LAST_PART=${TOKENS[${#TOKENS[@]} - 1]}
        #       sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_MASTER 'touch '$DB_TRIGER_FILE_PATH'/'$DB_TRIGER_FILE.$DB_PORT

                #>>>>>>note online should change to down
                        if [ "$LAST_PART" = "down,recovery" ] || [ "$LAST_PART" = "down" ]

                        then
                        return 0;
                        else
                        return 1;
                        fi
                else
                return 1;
                fi

}



PR_INTERFACE=$(ifconfig $PRIMARY_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
echo $PR_INTERFACE


while true 
#sleep $sleepTime; 
do
VIR_IP=$(ifconfig $VIRTUAL_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
if [ "$VIR_IP" = "$PG_IP_VIRTUAL" ]
then
sleepTime="15"
else
sleepTime="30"
fi

if [ "$ACTIVE_SERVER" = "slave" ]
then
sleepTime="10"
sleep $sleepTime;
echo "Alarm Slave server Activates... "
sshpass -p DuoS123 ssh root@192.168.4.5  'echo "Secondry Server Activated" | mail -s "Postgres Notify" dasun@duosoftware.com'

else
sleep $sleepTime;

ServiceStatus
PID=$?
	if [ -z "$VIR_IP" ]
	then
	ServerStatus
	conn=$?
		if [ "$conn" = "0" ]
		then
		./pgTestRecovery.sh
			if [ "$PR_INTERFACE" = "$PG_IP_PRIMARY" ]
                        then
			echo " alarm Secondry server connection refused "
			else
			echo " alarm Primary server connection refused "
			fi
		else
		echo "PG connection working"
		fi
	else
		if [ "$PID" = "1" ]
		then
		echo "Service Working"
		echo $PID
		else
		ifdown $VIRTUAL_INTERFACE
#			PR_INTERFACE=$(ifconfig $PRIMARY_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
#			echo $PR_INTERFACE
			if [ "$PR_INTERFACE" = "$PG_IP_PRIMARY" ]
			then
				sshpass -p $PASSWORD ssh $USER_NAME@$PG_IP_SECONDRY '/usr/src/pgTestRecovery.sh'
	        		echo " alarm Primary Server Crashed on $PG_IP_PRIMARY"
				sshpass -p DuoS123 ssh root@192.168.4.5  'echo "Primary Server crashed" | mail -s "Postgres Notify" dasun@duosoftware.com'

			else
				sshpass -p $PASSWORD ssh $USER_NAME@$PG_IP_PRIMARY '/usr/src/pgTestRecovery.sh'
                                echo " alarm Secondry Server Crashed on $PG_IP_SECONDRY"
				sshpass -p DuoS123 ssh root@192.168.4.5  'echo "Secondry Server crashed" | mail -s "Postgres Notify" dasun@duosoftware.com'

			fi
        	fi
	fi
fi
done
