#!/bin/bash
# Backup a Mongo database into a daily file.
BACKUP_DIR=/usr/src/
DAYS_TO_KEEP=2
MONGO_HOST=127.0.0.1
DATABASE=admin
USER=duouser
PASSWORD=DuoS123
FILE=`date +"%Y%m%d%H%M"`
OUTPUT_FILE=${BACKUP_DIR}/${FILE}
mongodump -h $MONGO_HOST -d $DATABASE -u $USER -p $PASSWORD -o $OUTPUT_FILE
## gzip the mysql database dump file
tar -zcvf $OUTPUT_FILE.tar.gz -C $OUTPUT_FILE .
rm -rf $OUTPUT_FILE
# prune old backups
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*.tar.gz" -exec rm -rf '{}' ';'

