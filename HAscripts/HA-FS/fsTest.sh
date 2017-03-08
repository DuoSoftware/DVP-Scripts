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

	CON=$(nc -z -v -w5 $FS_IP_VIRTUAL 22 2>&1)
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

PR_INTERFACE=$(ifconfig $PRIMARY_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
echo $PR_INTERFACE


while true 
#sleep $sleepTime; 
do
VIR_IP=$(ifconfig $VIRTUAL_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
if [ "$VIR_IP" = "$FS_IP_VIRTUAL" ]
then
sleepTime="1"
else
sleepTime="15"
fi

sleep $sleepTime;
PID=$(pidof freeswitch)
	if [ -z "$VIR_IP" ]
	then
	CheckServerCon
	conn=$?
		if [ "$conn" = "0" ]
		then
		./fsTestRecovery.sh
			if [ "$PR_INTERFACE" = "$FS_IP_PRIMARY" ]
                        then
			echo " alarm Secondry server connection refused "
			else
			echo " alarm Primary server connection refused "
			fi
		else
		echo "qq"
		fi
	else
		if [ ! -z "$PID" ]
		then
		echo "ll"
		echo $PID
		else
		ifdown $VIRTUAL_INTERFACE
#			PR_INTERFACE=$(ifconfig $PRIMARY_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
#			echo $PR_INTERFACE
			if [ "$PR_INTERFACE" = "$FS_IP_PRIMARY" ]
			then
				sshpass -p $PASSWORD ssh $USER_NAME@$FS_IP_SECONDRY '/usr/src/fsTestRecovery.sh'
	        		echo " alarm Primary Server Crashed on $FS_IP_PRIMARY"
			else
				sshpass -p $PASSWORD ssh $USER_NAME@$FS_IP_PRIMARY '/usr/src/fsTestRecovery.sh'
                                echo " alarm Secondry Server Crashed on $FS_IP_SECONDRY"
			fi
        	fi

	fi
done
