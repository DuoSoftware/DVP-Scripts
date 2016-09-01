#!/bin/bash
MONTHS=10;
SRC_DIR="/usr/recordings";
DST_DIR="/home/dasun/BAK";

while [ false ]; do
 sleep 60
#num++;
TIME=$(date +"%H:%M");
echo $TIME;
if [ "$TIME" == "23.59" ];then
#echo "BBBB";

cd $DST_DIR/;
DIR=$(date +%Y-%m-%d);
#echo $DIR;
mkdir $DIR;
chmod +x $DIR;
cp $SRC_DIR/* $DST_DIR/$DIR;

YESTERDAYDIR=$(date -d "1 day ago" +%F);
tar -zcf $YESTERDAYDIR.tar.gz $YESTERDAYDIR;
rm -rf $YESTERDAYDIR;

OLDDIR=$(date -d "$MONTHS month ago" +%F);
OLDFILE=$OLDDIR.tar.gz;
rm -rf $OLDFILE;
#echo $OLDDIR;

fi
done;

