#!/bin/bash
#
# Freeswitch Voice Clip backup-script
# run on crontab set time 23:59
# DAYS_TO_KEEP = number of days to keep voice files Ex : for a month  "DAYS_TO_KEEP=30"
DAYS_TO_KEEP=5
INBOUND_SRC_DIR=/usr/src/recordings
OUTBOUND_SRC_DIR=/usr/src/recordings-outbound
INBOUND_BACKUP_DIR=/usr/src/backup-inbound
OUTBOUND_BACKUP_DIR=/usr/src/backup-outbound

#DIR=$(date +%Y-%m-%d)
YESTERDAYDIR=$(date -d "1 day ago" +%F);
mkdir -p ${INBOUND_BACKUP_DIR}/${YESTERDAYDIR}
mkdir -p ${OUTBOUND_BACKUP_DIR}/${YESTERDAYDIR}

OUTPUT_INBOUND=${INBOUND_BACKUP_DIR}/${YESTERDAYDIR}
OUTPUT_OUTBOUND=${OUTBOUND_BACKUP_DIR}/${YESTERDAYDIR}


##mv $INBOUND_SRC_DIR/* $OUTPUT_INBOUND
#mv $OUTBOUND_SRC_DIR/* $OUTPUT_OUTBOUND
find $INBOUND_SRC_DIR -type f -mtime 1 -exec mv "{}" $OUTPUT_INBOUND \;
find $OUTBOUND_SRC_DIR -type f -mtime 1 -exec mv "{}" $OUTPUT_OUTBOUND \;

#YESTERDAYDIR=$(date -d "1 day ago" +%F);
cd ${INBOUND_BACKUP_DIR}
tar -zcf ${YESTERDAYDIR}.tar.gz $YESTERDAYDIR
rm -rf ${YESTERDAYDIR}

cd ${OUTBOUND_BACKUP_DIR}
tar -zcf ${YESTERDAYDIR}.tar.gz ${YESTERDAYDIR}
rm -rf ${YESTERDAYDIR}

find $INBOUND_BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*.tar.gz" -exec rm -rf '{}' ';'
find $OUTBOUND_BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*.tar.gz" -exec rm -rf '{}' ';'

