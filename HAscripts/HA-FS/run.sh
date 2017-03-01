#!/bin/bash
. params.conf

apt-get install -y arping sshpass
PR_INTERFACE=$(ifconfig $PRIMARY_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
chmod +x fsTest.sh
chmod +x fsTestRecovery.sh

if [ "$PR_INTERFACE" = "$FS_IP_PRIMARY" ]
then
	scp test.cfg $USER_NAME@$FS_IP_SECONDRY:/usr/src/
	echo " alarm Secondry server connection refused "
else
	scp test.cfg $USER_NAME@$FS_IP_PRIMARY:/usr/src/
	echo " alarm Primary server connection refused "
fi

#scp test.cfg $USER_NAME@
