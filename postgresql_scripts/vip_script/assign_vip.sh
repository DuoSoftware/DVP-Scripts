#!/bin/bash
. /root/param.conf
VIP=$(ifconfig $VIRTUAL_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')
if [ -z "$VIP" ]
then
vip=$(cat /etc/network/interfaces | grep $VIRTUAL_IP | cut -d ' ' -f 2)
if [ -z $vip ]
then
echo "Virtual IP Configurations Not found in /etc/networks/interface"
exit
else
ifup $VIRTUAL_INTERFACE
fi
fi
arping -q -c 3 -A -I $VIRTUAL_INTERFACE $VIRTUAL_IP

sleep 5
VIR_IP=$(ifconfig $VIRTUAL_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }')

if [ -z "$VIR_IP" ]
then
echo " $VIRTUAL_IP Not Assigned in this Server..!!!"
else
echo " VIP $VIRTUAL_IP Assigned"
 IP=$(ifconfig $PG_SVR_INTERFACE | grep "inet " | awk -F'[: ]+' '{ print $4 }'| cut -d ' ' -f 2)
     echo $IP
     if [ $IP == $PG_SVR_1_IP ]
     then
        echo "IP address is equal, assigning server 2 IP as connection IP"
     CON_IP=$PG_SVR_2_IP
     else
        echo "IP address is not equal, assigning server 1 IP as connection IP"
     CON_IP=$PG_SVR_1_IP
     fi

        if [ ! -e "$PG_SVR_1_DATA_DIR/recovery.conf" ]; then
            echo " recovery.conf not found"
            echo "creating recovery.conf file"
            echo "standby_mode = 'on'" > $PG_SVR_1_DATA_DIR/recovery.conf
            echo "primary_conninfo = 'host=$CON_IP port=$PG_PORT user=$REP_USER password=$REP_PWD'" >> $PG_SVR_1_DATA_DIR/recovery.conf
            echo "trigger_file = '/tmp/postgresql.trigger.$PG_PORT'" >> $PG_SVR_1_DATA_DIR/recovery.conf
            service postgresql restart
        else
            echo "recovery.conf found"
            echo "renaming recovery.conf to recovery.done....."
            mv $PG_SVR_1_DATA_DIR/recovery.conf $PG_SVR_1_DATA_DIR/recovery.done
            echo "shutting down VIP interface"
            ifdown $VIRTUAL_INTERFACE
            echo "$VIRTUAL_INTERFACE is down now"
            echo "done"
            service postgresql restart
        fi
fi

echo "finished"
