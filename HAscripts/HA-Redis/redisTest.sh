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

	CON=$(nc -z -v -w5 $REDIS_IP_VIRTUAL 22 2>&1)
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

CON=$(nc -z -v -w5 $REDIS_IP_VIRTUAL 22 2>&1)
read -a CONSTATUS <<< "${CON}"
LAST_PART=${CONSTATUS[${#CONSTATUS[@]} - 1]}
if [ "$LAST_PART" = "succeeded!" ] || [ "$LAST_PART" = "open" ]
then
return 1;
else
sleep 5

CON2=$(nc -z -v -w5 $REDIS_IP_VIRTUAL 22 2>&1)
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


PR_INTERFACE=$(ifconfig $PRIMARY_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
echo $PR_INTERFACE


while true 
#sleep $sleepTime; 
do
VIR_IP=$(ifconfig $VIRTUAL_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
if [ "$VIR_IP" = "$REDIS_IP_VIRTUAL" ]
then
sleepTime="1"
else
sleepTime="15"
fi

sleep $sleepTime;
PID=$(pidof $REDIS_SERVICE)
	if [ -z "$VIR_IP" ]
	then
	ServerStatus
	conn=$?
		if [ "$conn" = "0" ]
		then
		./redisTestRecovery.sh
			if [ "$PR_INTERFACE" = "$REDIS_IP_PRIMARY" ]
                        then
			echo " alarm Secondry server connection refused "
			else
			echo " alarm Primary server connection refused "
			fi
		else
		echo "Redis on Slave: Connection to Master Established"
		fi
	else
		if [ ! -z "$PID" ]
		then
		echo "Redis Master Connection Working"
		echo $PID
		else
		ifdown $VIRTUAL_INTERFACE
#			PR_INTERFACE=$(ifconfig $PRIMARY_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
#			echo $PR_INTERFACE
			if [ "$PR_INTERFACE" = "$REDIS_IP_PRIMARY" ]
			then
				sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_IP_SECONDRY '/usr/src/RedisHA/redisTestRecovery.sh'
	        		echo " alarm Primary Server Crashed on $REDIS_IP_PRIMARY"
			else
				sshpass -p $PASSWORD ssh $USER_NAME@$REDIS_IP_PRIMARY '/usr/src/RedisHA/redisTestRecovery.sh'
                                echo " alarm Secondry Server Crashed on $REDIS_IP_SECONDRY"
			fi
        	fi

	fi
done
