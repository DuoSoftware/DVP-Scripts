#!/bin/bash
. recoveryparams.conf
#apt-get install sshpass
echo "Postgresql Recovery Starting....."
sleep 2
sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_SLAVE 'service '$DB_SERVICE' stop'
echo "Stopping Slave Postgresql Service..." 

sudo -u postgres psql -c "select pg_start_backup('initial_backup');"
sudo -u postgres rsync -cva --inplace --exclude=*pg_xlog* $MASTER_DATA_PATH $DB_SERVER_SLAVE:$SLAVE_DATA_PATH
sudo -u postgres psql -c "select pg_stop_backup();"

echo "Creating Recovery File...."
#apt-get install sshpass
echo "standby_mode = 'on'
primary_conninfo = 'host=$DB_SERVER_MASTER port=5432 user=$REPLICATION_USER password=$PASSWORD'
trigger_file = '$TRIGGER_PATH/postgresql.trigger.5432'" > /usr/src/recovery.conf
sshpass -p $PASSWORD scp recovery.conf root@$DB_SERVER_MASTER:$SLAVE_DATA_PATH
rm /usr/src/recovery.conf

sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_SLAVE 'rm $TRIGGER_PATH/postgresql.trigger.5432'
echo "Starting New Slave Postgres......."
sshpass -p $PASSWORD ssh $USER_NAME@$DB_SERVER_SLAVE 'service '$DB_SERVICE' start'

