#!/bin/bash
#config parameters on host.conf
#put loop as a cronjob
. host.conf

LIST=$(docker ps -a -q -f status=exited | sed -e 's/ /@/g');
#echo $LIST;

name=$1;

matchingStarted=$(docker ps --filter="name=$name,status=exited" -q | xargs);

#echo $matchingStarted;

IFS=' ' read -r -a array <<< "$matchingStarted";

#echo ${!array[@]};
DOCKER="";
for index in "${!array[@]}"
do
#echo "asasa";

echo  ${array[index]};
CONTAINER=${array[index]};
#done


#CONTAINER="9019cf97c634";
#CONTAINER=$1;

DOCKERNAME=$(docker inspect --format="{{.Name}}" $CONTAINER);
RUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER 2> /dev/null)
#echo $RUNNING;
#echo $AAA;
if [ $? -eq 1 ]; then
  echo "UNKNOWN - $AAA does not exist."
#  exit 3
fi

if [ "$RUNNING" == "false" ]; then
  #echo "CRITICAL - $AAA is not running."
DOCKER_1=${DOCKERNAME:1};
 # exit 2
fi

if [ "$RUNNING" == "true" ]; then
  echo "CRITICAL - $DOCKERNAME is running."
 # exit 1
fi

DOCKER="$DOCKER,$DOCKER_1";
#echo $DOCKER;
#echo $DOCKER_1;
done

#echo ">>>>>>>>>>>>>>>>>";
#timeout 3 docker stats notificationservice ardsliteroutingengine > docker.txt;
#docker stats notificationservice ardsliteroutingengine | tee -a "docker.txt";

#ppid= ${pidof docker stats notificationservice ardsliteroutingengine};

#echo $DOCKER;
DOCKER='"'${DOCKER:1}'"';
echo $DOCKER;
IP=$(ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')
#echo $IP;
if [ ! -z "$DOCKER" ]; then

#echo "AAAAAAAAAAAAAAAAAAA";
curl "http://$HOST/PHPMailer/PHPMailer/examples/sendmail.php?containers=$DOCKER&server=$IP";
fi
