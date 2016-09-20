#!/bin/bash

#config parameters on host.conf
. host.conf

LIST=$(docker ps -a -q -f status=up | sed -e 's/ /@/g');
#echo $LIST;

name=$1;

num=1;
while [ false ]; do
 sleep $TIME
num++;




matchingStarted=$(docker ps --filter="name=$name,status=running" -q | xargs);

#echo $matchingStarted;

IFS=' ' read -r -a array <<< "$matchingStarted";

#echo ${!array[@]};
DOCKER="";
for index in "${!array[@]}"
do
#echo "asasa";

#echo  ${array[index]};
CONTAINER=${array[index]};
#done

DOCKER_NAME=$(docker inspect --format="{{.Name}}" $CONTAINER);
RUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER 2> /dev/null)
#echo $RUNNING;
#echo $AAA;
if [ $? -eq 1 ]; then
  echo "UNKNOWN - $DOCKER_NAME does not exist."
#  exit 3
fi

if [ "$RUNNING" == "false" ]; then
  echo "CRITICAL - $DOCKER_NAME is not running."
#DOCKER_1=${AAA:1};
 # exit 2
fi

if [ "$RUNNING" == "true" ]; then
  echo "CRITICAL - $DOCKER_NAME is running."
DOCKER_1=${DOCKER_NAME:1};
 # exit 1
fi

DOCKER="$DOCKER $DOCKER_1";
echo $DOCKER;
#echo $DOCKER_1;
done

#echo ">>>>>>>>>>>>>>>>>";
IP=$(ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')
echo $IP;


FILE=$IP.log;
timeout 3 docker stats $DOCKER > $FILE ;
sleep 2;

if [ -f "$FILE" ]; then
echo "File Found";
#RTN=$(curl -F "uploadedfile=@/usr/src/$FILE" http://$HOST/PHPMailer/PHPMailer/examples/uploads.php);
curl -F "uploadedfile=@/usr/src/$FILE" http://$HOST/PHPMailer/PHPMailer/examples/uploads.php;
#	if [ "$RTN" == "success" ]; then
	curl "http://$HOST/PHPMailer/PHPMailer/examples/sendDockerStats.php?file=$FILE&server=$IP";
#	fi
echo "SSSSS";
fi
rm -f $FILE;
done
