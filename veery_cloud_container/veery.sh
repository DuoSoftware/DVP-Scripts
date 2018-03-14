#!/bin/bash

#IFS="="
. params.conf
. enable.conf
#while read -r name value
#read -r name value
#do
#echo "Content of $name is ${value//\"/}"< enable.conf
#done < enable.conf
#string= "$VAR1";
#echo $string;
#string="var1,var2,var3,var4";
DATE=`date +%Y-%m-%d`

IFS=', ' read -r -a array <<< "$DEPLOY";
#echo "${array[2]}";


#Install Docker

which curl
sudo apt-get install curl -y
curl -sSL https://get.docker.com/ | sh
curl -sSL https://get.docker.com/gpg | sudo apt-key add -

# Install Nginx-Proxy

cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"nginx-proxy:latest";
 docker tag $REPOSITORY_IPURL":5000"/"nginx-proxy:latest" "nginx-proxy:latest";
 docker rmi -f $REPOSITORY_IPURL":5000"/"nginx-proxy:latest";
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-ReverseProxy" ]; then
	git clone https://github.com/DuoSoftware/DVP-ReverseProxy.git;
fi
cd DVP-ReverseProxy;
docker build -t "nginx-proxy:latest" .
fi
cd /usr/src/;
docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro -v /etc/localtime:/etc/localtime:ro --log-opt max-size=10m --restart=always --log-opt max-file=10 --name nginx nginx-proxy

# install services

for index in "${!array[@]}"
do
 #   echo "$index ${array[index]}"


SERVICE=${array[index]}

case "$SERVICE" in
   "dynamicconfigurationgenerator")
#1
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"dynamicconfigurationgenerator:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"dynamicconfigurationgenerator:"$VERSION_TAG "dynamicconfigurationgenerator:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"dynamicconfigurationgenerator:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-DynamicConfigurationGenerator" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-DynamicConfigurationGenerator.git;
fi
cd DVP-DynamicConfigurationGenerator;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "dynamicconfigurationgenerator:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/dynamicconfigurationgenerator/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_CALL_RECORD_PATH=$OUTBOUND_RECORDING_PATH" --env="SYS_BILLING_ENABLED=$BILLING_ENABLED" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD" --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION"  --env="HOST_DYNAMICCONFIGGEN_PORT=8816" --env="HOST_USE_DASHBOARD_MSG_QUEUE=$DASHBOARD_USE_MSG_QUEUE" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=dynamicconfigurationgenerator.*" --env="LB_FRONTEND=dynamicconfigurationgenerator.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8816/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name dynamicconfigurationgenerator dynamicconfigurationgenerator:$VERSION_TAG node /usr/local/src/dynamicconfigurationgenerator/app.js;
;;

   "resourceservice")
#2
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"resourceservice:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"resourceservice:"$VERSION_TAG "resourceservice:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"resourceservice:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-ResourceService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-ResourceService.git;
fi

cd DVP-ResourceService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "resourceservice:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/resourceservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_RESOURCESERVICE_PORT=8831" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_DASHBOARD_REDIS_HOST=$DASHBOARD_REDIS_HOST" --env="SYS_DASHBOARD_REDIS_PORT=$DASHBOARD_REDIS_PORT" --env="SYS_DASHBOARD_REDIS_PASSWORD=$DASHBOARD_REDIS_PASSWORD" --env="SYS_REDIS_DB_DASHBOARD=$REDIS_DB_DASHBOARD" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=resourceservice.*" --env="LB_FRONTEND=resourceservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8831/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name resourceservice resourceservice:$VERSION_TAG node /usr/local/src/resourceservice/app.js;

;;
   "ardsmonitoring")
#3
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"ardsmonitoring:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"ardsmonitoring:"$VERSION_TAG "ardsmonitoring:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"ardsmonitoring:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-ARDSMonitoring" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-ARDSMonitoring.git;
fi

cd DVP-ARDSMonitoring;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "ardsmonitoring:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/ardsmonitoring/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ARDSMONITOR_PORT=8830" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD" --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --env="SYS_CDRPROCESSOR_HOST=cdrprocessor.$FRONTEND" --env="SYS_CDRPROCESSOR_PORT=8809" --env="SYS_CDRPROCESSOR_VERSION=$HOST_VERSION" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="SYS_NOTIFICATIONSERVICE_VERSION=$HOST_VERSION" --env="SYS_ARDSLITEROUTINGENGINE_HOST=ardsliteroutingengine.$FRONTEND" --env="SYS_ARDSLITEROUTINGENGINE_PORT=8835" --env="SYS_ARDSLITEROUTINGENGINE_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="VIRTUAL_HOST=ardsmonitoring.*" --env="LB_FRONTEND=ardsmonitoring.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8830/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ardsmonitoring ardsmonitoring:$VERSION_TAG node /usr/local/src/ardsmonitoring/app.js;

;;
   "phonenumbertrunkservice")
#4
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"phonenumbertrunkservice:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"phonenumbertrunkservice:"$VERSION_TAG "phonenumbertrunkservice:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"phonenumbertrunkservice:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-PhoneNumberTrunkService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-PhoneNumberTrunkService.git;
fi

cd DVP-PhoneNumberTrunkService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "phonenumbertrunkservice:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/phonenumbertrunkservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_PHONENUMBERTRUNKSERVICE_PORT=8818" --env="SYS_LIMITHANDLER_HOST=limithandler.$FRONTEND" --env="SYS_LIMITHANDLER_PORT=8815" --env="SYS_LIMITHANDLER_VERSION+$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=phonenumbertrunkservice.*" --env="LB_FRONTEND=phonenumbertrunkservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8818/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name phonenumbertrunkservice phonenumbertrunkservice:$VERSION_TAG node /usr/local/src/phonenumbertrunkservice/app.js;
;;

 "limithandler")
#5
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"limithandler:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"limithandler:"$VERSION_TAG "limithandler:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"limithandler:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-LimitHandler" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-LimitHandler.git;
fi

cd DVP-LimitHandler;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "limithandler:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/limithandler/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_LIMITHANDLER_PORT=8815" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=limithandler.*" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="LB_FRONTEND=limithandler.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_VERSION=$HOST_VERSION" --env="SYS_USERSERVICE_HOST=userservice.$FRONTEND" --env="SYS_USERSERVICE_VERSION=$HOST_VERSION" --env="SYS_APPREGISTRY_HOST=appregistry.$FRONTEND" --env="SYS_APPREGISTRY_VERSION=$HOST_VERSION" --expose=8815/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name limithandler limithandler:$VERSION_TAG node /usr/local/src/limithandler/app.js;

;;
   "ardsliteroutingengine")
#6
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
IFS='.' read -ra VER <<< "$GO_VERSION_TAG"
 docker pull $REPOSITORY_IPURL":5000"/"ardsliteroutingengine:"$GO_VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"ardsliteroutingengine:"$GO_VERSION_TAG "ardsliteroutingengine:"$GO_VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"ardsliteroutingengine:"$GO_VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-ARDSLiteRoutingEngine" ]; then
	git clone -b $GO_VERSION_TAG https://github.com/DuoSoftware/DVP-ARDSLiteRoutingEngine.git;
fi

cd DVP-ARDSLiteRoutingEngine;
IFS='.' read -ra VER <<< "$GO_VERSION_TAG"
docker build --build-arg MAJOR_VER=${VER[0]} -t "ardsliteroutingengine:"$GO_VERSION_TAG .;
#docker build -t "ardsliteroutingengine:latest" .;
fi
cd /usr/src/;
##docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="GO_CONFIG_DIR=/go/src/gopkg.in/DuoSoftware/DVP-ARDSLiteRoutingEngine.v2/ArdsLiteRoutingEngine" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ARDSLITEROUTINGENGINE_ID=$ARDSLITEROUTINGENGINE_ID" --env="HOST_USE_MSG_QUEUE=$ARDS_USE_MSG_QUEUE" --env="SYS_REDIS_DB_LOCATION=$REDIS_DB_LOCATION" --env="HOST_ARDSLITEROUTINGENGINE_PORT=8835" --env="HOST_IP=$HOST_IP"  --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="VIRTUAL_HOST=ardsliteroutingengine.*" --env="LB_FRONTEND=ardsliteroutingengine.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --expose=8835/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ardsliteroutingengine ardsliteroutingengine go run *.go;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$GO_VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-ARDSLiteRoutingEngine/ArdsLiteRoutingEngine" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ARDSLITEROUTINGENGINE_ID=$ARDSLITEROUTINGENGINE_ID" --env="HOST_USE_MSG_QUEUE=$ARDS_USE_MSG_QUEUE" --env="SYS_REDIS_DB_LOCATION=$REDIS_DB_LOCATION" --env="HOST_ARDSLITEROUTINGENGINE_PORT=8835" --env="HOST_IP=$HOST_IP"  --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="VIRTUAL_HOST=ardsliteroutingengine.*" --env="LB_FRONTEND=ardsliteroutingengine.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --expose=8835/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ardsliteroutingengine ardsliteroutingengine:$GO_VERSION_TAG go run *.go;
;;

   "notificationservice")
#7
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"notificationservice:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"notificationservice:"$VERSION_TAG "notificationservice:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"notificationservice:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-NotificationServicee" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-NotificationService.git;
fi

cd DVP-NotificationService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "notificationservice:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/notificationservice/config" --env="SYS_CRM_ENABLE=$CRM_ENABLE" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_NOTIFICATIONSERVICE_PORT=8833" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_CRMINTEGRATION_HOST=crmintegrations.app.veery.cloud" --env="SYS_CRMINTEGRATION_PORT=8894" --env="SYS_CRMINTEGRATION_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=notificationservice.*" --env="LB_FRONTEND=notificationservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8833/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name notificationservice notificationservice:$VERSION_TAG node /usr/local/src/notificationservice/app.js;
;;

   "engagementservice")
#8
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"engagementservice:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"engagementservice:"$VERSION_TAG "engagementservice:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"engagementservice:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-Engagement" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-Engagement.git;
fi

cd DVP-Engagement;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "engagementservice:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/engagementservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ENGAGEMENTSERVICE_PORT=8834" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="VIRTUAL_HOST=engagementservice.*" --env="LB_FRONTEND=engagementservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8834/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name engagementservice engagementservice:$VERSION_TAG node /usr/local/src/engagementservice/app.js;
;;
   "campaignmanager")
#9
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"campaignmanager:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"campaignmanager:"$VERSION_TAG "campaignmanager:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"campaignmanager:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-CampaignManager" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-CampaignManager.git;
fi

cd DVP-CampaignManager;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "campaignmanager:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/campaignmanager/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CAMPAIGNMANAGER_PORT=8827" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=campaignmanager.*" --env="LB_FRONTEND=campaignmanager.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8827/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name campaignmanager campaignmanager:$VERSION_TAG node /usr/local/src/campaignmanager/app.js;

;;
   "pbxservice")
#10
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"pbxservice:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"pbxservice:"$VERSION_TAG "pbxservice:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"pbxservice:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-PBXService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-PBXService.git;
fi

cd DVP-PBXService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "pbxservice:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/pbxservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_PBXSERVICE_PORT=8820" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_SIPUSERSERVICE_HOST=sipuserendpointservice.$FRONTEND" --env="SYS_SIPUSERSERVICE_NODE_CONFIG_DIR=/usr/local/src/sipuserendpointservice/config" --env="SYS_SIPUSERSERVICE_PORT=8814"  --env="SYS_SIPUSERSERVICE_VERSION=$HOST_VERSION" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_NODE_CONFIG_DIR=/usr/local/src/fileservice/config" --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=pbxservice.*" --env="LB_FRONTEND=pbxservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8820/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name pbxservice pbxservice:$VERSION_TAG node /usr/local/src/pbxservice/app.js;

;;
   "callbackservice")
#11
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
IFS='.' read -ra VER <<< "$GO_VERSION_TAG"
 docker pull $REPOSITORY_IPURL":5000"/"callbackservice:"$GO_VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"callbackservice:"$GO_VERSION_TAG "callbackservice:"$GO_VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"callbackservice:"$GO_VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-CallBackService" ]; then
	git clone -b $GO_VERSION_TAG https://github.com/DuoSoftware/DVP-CallBackService.git;
fi

cd DVP-CallBackService;
IFS='.' read -ra VER <<< "$GO_VERSION_TAG"
#docker build --build-arg MAJOR_VER=${VER[0]} -t "callbackservice:"$GO_VERSION_TAG .;
docker build -t "callbackservice:latest" .;
fi
cd /usr/src/;
#docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$GO_VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="GO_CONFIG_DIR=/go/src/gopkg.in/DuoSoftware/DVP-CallBackService.${VER[0]}/CallbackServer" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CALLBACKSERVICE_PORT=8840" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_CAMPAIGNMANAGER_HOST=campaignmanager.$FRONTEND" --env="SYS_CAMPAIGNMANAGER_NODE_CONFIG_DIR=/usr/local/src/campaignmanager/config" --env="SYS_CAMPAIGNMANAGER_PORT=8827" --env="SYS_DIALER_HOST=dialerapi.$FRONTEND" --env="SYS_DIALER_PORT=8836" --env="VIRTUAL_HOST=callbackservice.*" --env="LB_FRONTEND=callbackservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8840/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name callbackservice callbackservice:$GO_VERSION_TAG go run *.go;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$GO_VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-CallBackService/CallbackServer" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CALLBACKSERVICE_PORT=8840" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_CAMPAIGNMANAGER_HOST=campaignmanager.$FRONTEND" --env="SYS_CAMPAIGNMANAGER_NODE_CONFIG_DIR=/usr/local/src/campaignmanager/config" --env="SYS_CAMPAIGNMANAGER_PORT=8827" --env="SYS_DIALER_HOST=dialerapi.$FRONTEND" --env="SYS_DIALER_PORT=8836" --env="VIRTUAL_HOST=callbackservice.*" --env="LB_FRONTEND=callbackservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8840/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name callbackservice callbackservice go run *.go;
;;
   "voxboneapi")
#12
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"voxboneapi:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"voxboneapi:"$VERSION_TAG "voxboneapi:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"voxboneapi:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-VoxboneAPI" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-VoxboneAPI.git;
fi

cd DVP-VoxboneAPI;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "voxboneapi:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/voxboneapi/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_RULESERVICE_HOST=ruleservice.$FRONTEND" --env="SYS_RULESERVICE_PORT=8817" --env="SYS_RULESERVICE_VERSION=$HOST_VERSION" --env="VOXBONE_URL=https://api.voxbone.com/ws-voxbone/services/rest" --env="HOST_VOXBONEAPI_PORT=8832" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_PHONENUMBERTRUNKSERVICE_HOST=phonenumbertrunkservice.$FRONTEND" --env="SYS_PHONENUMBERTRUNKSERVICE_NODE_CONFIG_DIR=/usr/local/src/phonenumbertrunkservice/config" --env="SYS_PHONENUMBERTRUNKSERVICE_PORT=8818" --env="SYS_PHONENUMBERTRUNKSERVICE_VERSION=$HOST_VERSION" --env="SYS_LIMITHANDLER_HOST=limithandler.$FRONTEND" --env="SYS_LIMITHANDLER_NODE_CONFIG_DIR=/usr/local/src/limithandler/config" --env="SYS_LIMITHANDLER_PORT=8815" --env="SYS_LIMITHANDLER_VERSION=$HOST_VERSION" --env="SYS_BILLINGSERVICE_HOST=billingservice.$FRONTEND" --env="SYS_BILLINGSERVICE_PORT=$LB_PORT" --env="SYS_BILLINGSERVICE_VERSION=$HOST_VERSION" --env="SYS_WALLETSERVICE_HOST=walletservice.$FRONTEND" --env="SYS_WALLETSERVICE_PORT=$LB_PORT" --env="SYS_WALLETSERVICE_VERSION=$HOST_VERSION"  --env="VOX_APIKEY=$VOX_KEY" --env="VIRTUAL_HOST=voxboneapi.*" --env="LB_FRONTEND=voxboneapi.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8832/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name voxboneapi voxboneapi:$VERSION_TAG node /usr/local/src/voxboneapi/app.js;

;;
   "ruleservice")
#13
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"ruleservice:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"ruleservice:"$VERSION_TAG "ruleservice:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"ruleservice:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-RuleService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-RuleService.git;
fi

cd DVP-RuleService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "ruleservice:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/ruleservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_RULESERVICE_PORT=8817" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_HTTPROGRAMMINGAPI_HOST=httpprogrammingapi.$FRONTEND" --env="SYS_HTTPROGRAMMINGAPI_PORT=$LB_PORT" --env="SYS_HTTPROGRAMMINGAPI_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=ruleservice.*" --env="LB_FRONTEND=ruleservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8817/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ruleservice ruleservice:$VERSION_TAG node /usr/local/src/ruleservice/app.js;

;;
   "conference")
#14
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"conference:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"conference:"$VERSION_TAG "conference:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"conference:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-Conference" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-Conference.git;
fi

cd DVP-Conference;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "conference:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/conference/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="HOST_NAME=conference" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_CONFERENCE_PORT=8821" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=conference.*" --env="LB_FRONTEND=conference.$FRONTEND" --env="LB_PORT=LB_PORT" --expose 8821 --log-opt max-size=10m --log-opt max-file=10 --restart=always --name conference conference:$VERSION_TAG node /usr/local/src/conference/app.js;

;;
   "httpprogrammingapidebug")
#15
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"httpprogrammingapidebug:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"httpprogrammingapidebug:"$VERSION_TAG "httpprogrammingapidebug:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"httpprogrammingapidebug:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-HTTPProgrammingAPIDEBUG" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-HTTPProgrammingAPIDEBUG.git;
fi

cd DVP-HTTPProgrammingAPIDEBUG;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "httpprogrammingapidebug:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/httpprogrammingapidebug/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_HTTPPROGRAMMINGAPIDEBUG_PORT=8825" ---env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_HTTPPROGRAMMINGAPI_HOST=httpprogrammingapi.$FRONTEND" --env="VIRTUAL_HOST=httpprogrammingapidebug.*" --env="LB_FRONTEND=httpprogrammingapidebug.$FRONTEND" --env="LB_PORT=LB_PORT" --expose=8825/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name httpprogrammingapidebug httpprogrammingapidebug:$VERSION_TAG node /usr/local/src/httpprogrammingapidebug/app.js;

;;
   "interactions")
#16
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"interactions:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"interactions:"$VERSION_TAG "interactions:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"interactions:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-Interactions" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-Interactions.git;
fi

cd DVP-Interactions;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "interactions:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/interactions/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="EXTERNAL_PROFILE_SEARCH=$EXTERNAL_PROFILE_SEARCH" --env="HOST_INTERACTIONS_PORT=8873" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="VIRTUAL_HOST=interactions.*" --env="LB_FRONTEND=interactions.$FRONTEND" --env="LB_PORT=LB_PORT" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_SIPUSERENDPOINTSERVICE_HOST=sipuserendpointservice.$FRONTEND" --env="SYS_SIPUSERENDPOINTSERVICE_PORT=8814" --env="SYS_SIPUSERENDPOINTSERVICE_VERSION=$HOST_VERSION" --env="SYS_CLUSTERCONFIG_HOST=clusterconfig.$FRONTEND" --env="SYS_CLUSTERCONFIG_PORT=8805" --env="SYS_CLUSTERCONFIG_VERSION=$HOST_VERSION" --expose=8873/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name interactions interactions:$VERSION_TAG node /usr/local/src/interactions/app.js

;;
   "templates")
#17
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"templates:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"templates:"$VERSION_TAG "templates:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"templates:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-Templates" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-Templates.git
fi

cd DVP-Templates;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "templates:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/templates/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_TEMPLATE_PORT=8875" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="VIRTUAL_HOST=templates.*" --env="LB_FRONTEND=templates.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8875/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name templates templates:$VERSION_TAG node /usr/local/src/templates/app.js;

;;
   "ardsliteservice")
#18
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"ardsliteservice:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"ardsliteservice:"$VERSION_TAG "ardsliteservice:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"ardsliteservice:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-ARDSLiteService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-ARDSLiteService.git;
fi

cd DVP-ARDSLiteService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "ardsliteservice:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/ardsliteservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ARDSLITESERVICE_PORT=8828" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_ARDSLITEROUTINGENGINE_HOST=ardsliteroutingengine.$FRONTEND" --env="SYS_ARDSLITEROUTINGENGINE_GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-ARDSLiteRoutingEngine/ArdsLiteRoutingEngine" --env="SYS_ARDSLITEROUTINGENGINE_PORT=8835" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=ardsliteservice.*" --env="LB_FRONTEND=ardsliteservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_SCHEDULEWORKER_HOST=scheduleworker.$FRONTEND" --env="SYS_SCHEDULEWORKER_PORT=8852" --env="SYS_SCHEDULEWORKER_VERSION=$HOST_VERSION" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_VERSION=$HOST_VERSION" --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="SYS_ARDSMONITORING_HOST=ardsmonitoring.$FRONTEND" --env="SYS_ARDSMONITORING_PORT=8830" --env="SYS_ARDSMONITORING_VERSION=$HOST_VERSION" --env="HOST_USE_MSG_QUEUE=$ARDS_USE_MSG_QUEUE" --env="HOST_USE_DASHBOARD_MSG_QUEUE=$DASHBOARD_USE_MSG_QUEUE" --expose=8828/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ardsliteservice ardsliteservice:$VERSION_TAG node /usr/local/src/ardsliteservice/app.js;

;;
   "userservice")
#19
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"userservice:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"userservice:"$VERSION_TAG "userservice:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"userservice:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-UserService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-UserService.git;
fi

cd DVP-UserService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "userservice:"$VERSION_TAG .;
fi
cd /usr/src/;
#docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env='NODE_CONFIG_DIR=/usr/local/src/userservice/config' --env="EXTERNAL_PROFILE_SEARCH=$EXTERNAL_PROFILE_SEARCH" --env="HOST_TOKEN=$HOST_TOKEN" --env="ACTIVE_TENANT=$TENANT" --env="HOST_USERSERVICE_PORT=8842" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="VIRTUAL_HOST=userservice.*" --env="LB_FRONTEND=userservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_SIPUSERENDPOINTSERVICE_HOST=sipuserendpointservice.$FRONTEND" --env="SYS_SIPUSERENDPOINTSERVICE_PORT=8814" --env="SYS_SIPUSERENDPOINTSERVICE_VERSION=$HOST_VERSION" --env="SYS_CLUSTERCONFIG_HOST=clusterconfig.$FRONTEND" --env="SYS_CLUSTERCONFIG_PORT=8805" --env="SYS_CLUSTERCONFIG_VERSION=$HOST_VERSION" --env="FACEBOOK_CLIENT_SECRET=$FACEBOOK_PWD" --env="FOURSQUARE_CLIENT_SECRET=$FOURSQUARE_PWD" --env="GOOGLE_CLIENT_SECRET=$GOOGLE_PWD" --env="GITHUB_CLIENT_SECRET=$GITHUB_PWD" --env="INSTAGRAM_CLIENT_SECRET=$INSTAGRAM_PWD" --env="LINKEDIN_CLIENT_SECRET=$LINKEDIN_PWD" --env="TWITCH_CLIENT_SECRET=$TWITCH_PWD" --env="MICROSOFT_CLIENT_SECRET=$WINDOWS_PWD" --env="YAHOO_CLIENT_SECRET=$YAHOO_PWD" --env="BITBUCKET_CLIENT_SECRET=$BITBUCKET_PWD" --env="SPOTIFY_CLIENT_SECRET=$SPOTIFY_PWD" --env="TWITTER_CLIENT_KEY=$TWITTER_KEY" --env="TWITTER_CLIENT_SECRET=$TWITTER_PWD" --env="LOGIN_VERIFICATION_REQUIRE=$LOGIN_VERIFICATION" --env="SIGNUP_VERIFICATION_REQUIRE=$SIGNUP_VERIFICATION" --env="GOOGLE_RECAPTCHA_KEY=$GOOGLE_RECAPTCHA_KEY" --env="SYS_APP_UI_HOST=$APP_UI_HOST" --env="SYS_BILLINGSERVICE_HOST=billingservice.$FRONTEND" --env="SYS_BILLINGSERVICE_PORT=$LB_PORT" --env="SYS_APP_AGENT_UI_HOST=$APP_AGENT_UI" --env="SYS_BILLINGSERVICE_VERSION=$HOST_VERSION" --env="HOST_CLUSTER_CODE=$CLUSTER_CODE" --env="HOST_PROVISION_MECHANISM=$PROVISION_MECHANISM" --expose=8842/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name userservice userservice:$VERSION_TAG node /usr/local/src/userservice/app.js
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env='NODE_CONFIG_DIR=/usr/local/src/userservice/config' --env="EXTERNAL_PROFILE_SEARCH=$EXTERNAL_PROFILE_SEARCH" --env="HOST_TOKEN=$HOST_TOKEN" --env="ACTIVE_TENANT=$TENANT" --env="HOST_USERSERVICE_PORT=8842" --env="HOST_VERSION=$HOST_VERSION" --env="ACTIVE_COMPANY=$ACTIVE_COMPANYID" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="VIRTUAL_HOST=userservice.*" --env="LB_FRONTEND=userservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_SIPUSERENDPOINTSERVICE_HOST=sipuserendpointservice.$FRONTEND" --env="SYS_SIPUSERENDPOINTSERVICE_PORT=8814" --env="SYS_SIPUSERENDPOINTSERVICE_VERSION=$HOST_VERSION" --env="SYS_CLUSTERCONFIG_HOST=clusterconfig.$FRONTEND" --env="SYS_CLUSTERCONFIG_PORT=8805" --env="SYS_CLUSTERCONFIG_VERSION=$HOST_VERSION" --env="FACEBOOK_CLIENT_SECRET=$FACEBOOK_PWD" --env="FOURSQUARE_CLIENT_SECRET=$FOURSQUARE_PWD" --env="GOOGLE_CLIENT_SECRET=$GOOGLE_PWD" --env="GITHUB_CLIENT_SECRET=$GITHUB_PWD" --env="INSTAGRAM_CLIENT_SECRET=$INSTAGRAM_PWD" --env="LINKEDIN_CLIENT_SECRET=$LINKEDIN_PWD" --env="TWITCH_CLIENT_SECRET=$TWITCH_PWD" --env="MICROSOFT_CLIENT_SECRET=$WINDOWS_PWD" --env="YAHOO_CLIENT_SECRET=$YAHOO_PWD" --env="BITBUCKET_CLIENT_SECRET=$BITBUCKET_PWD" --env="SPOTIFY_CLIENT_SECRET=$SPOTIFY_PWD" --env="TWITTER_CLIENT_KEY=$TWITTER_KEY" --env="TWITTER_CLIENT_SECRET=$TWITTER_PWD" --env="LOGIN_VERIFICATION_REQUIRE=$LOGIN_VERIFICATION" --env="SIGNUP_VERIFICATION_REQUIRE=$SIGNUP_VERIFICATION" --env="GOOGLE_RECAPTCHA_KEY=$GOOGLE_RECAPTCHA_KEY" --env="SYS_APP_UI_HOST=$APP_UI_HOST" --env="SYS_BILLINGSERVICE_HOST=billingservice.$FRONTEND" --env="SYS_BILLINGSERVICE_PORT=$LB_PORT" --env="SYS_APP_AGENT_UI_HOST=$APP_AGENT_UI" --env="SYS_BILLINGSERVICE_VERSION=$HOST_VERSION" --env="SYS_RULESERVICE_HOST=ruleservice.$FRONTEND" --env="SYS_RULESERVICE_PORT=$LB_PORT" --env="SYS_RULESERVICE_VERSION=$HOST_VERSION" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_PORT=$LB_PORT" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --env="SYS_LITETICKET_HOST=liteticket.$FRONTEND" --env="SYS_LITETICKET_PORT=$LB_PORT" --env="SYS_LITETICKET_VERSION=$HOST_VERSION" --env="HOST_CLUSTER_NAME=$CLUSTER_NAME" --env="HOST_PROVISION_MECHANISM=$PROVISION_MECHANISM" --expose=8842/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name userservice userservice:$VERSION_TAG node /usr/local/src/userservice/app.js
;;

   "monitorrestapi")
#20
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"monitorrestapi:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"monitorrestapi:"$VERSION_TAG "monitorrestapi:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"monitorrestapi:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-MonitorRestAPI" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-MonitorRestAPI.git;
fi

cd DVP-MonitorRestAPI;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "monitorrestapi:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/monitorrestapi/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_MONITORRESTAPI_PORT=8823" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=monitorrestapi.*" --env="LB_FRONTEND=monitorrestapi.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8823/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name monitorrestapi monitorrestapi:$VERSION_TAG node /usr/local/src/monitorrestapi/app.js;

;;
   "httpprogrammingapi")
#21-
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"httpprogrammingapi:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"httpprogrammingapi:"$VERSION_TAG "httpprogrammingapi:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"httpprogrammingapi:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-HTTPProgrammingAPI" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-HTTPProgrammingAPI.git;
fi

cd DVP-HTTPProgrammingAPI;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "httpprogrammingapi:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/httpprogrammingapi/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_FREESWITCH_HOST=$FREESWITCH_HOST"  --env="SYS_EVENTSOCKET_PORT=$EVENTSOCKET_PORT" --env="FS_PASSWORD=$FREESWITCH_EVENTSOCKET_PASSWORD" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="HOST_HTTPPROGRAMMINGAPI_PORT=8807" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_NODE_CONFIG_DIR=/usr/local/src/fileservice/config" --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --env="SYS_DOWNLOAD_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_DOWNLOAD_FILESERVICE_PORT=8812" --env="SYS_DOWNLOAD_FILESERVICE_VERSION=$HOST_VERSION" --env="SYS_RULESERVICE_HOST=ruleservice.$FRONTEND" --env="SYS_RULESERVICE_PORT=8817" --env="SYS_RULESERVICE_VERSION=$HOST_VERSION" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_NODE_CONFIG_DIR=/usr/local/src/ardsliteservice/config" --env="SYS_ARDSLITESERVICE_PORT=8828" --env="SYS_QUEUEMUSIC_HOST=queuemusic.$FRONTEND" --env="SYS_QUEUEMUSIC_PORT=8842" --env="SYS_QUEUEMUSIC_VERSION=$HOST_VERSION" --env="SYS_INTERACTION_HOST=interactions.$FRONTEND" --env="SYS_INTERACTION_PORT=8873" --env="SYS_INTERACTION_VERSION=$HOST_VERSION" --env="SYS_TICKET_HOST=liteticket.$FRONTEND" --env="SYS_TICKET_PORT=8872" --env="SYS_TICKET_VERSION=1.0.0.0" --env="VIRTUAL_HOST=httpprogrammingapi.*" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="LB_FRONTEND=httpprogrammingapi.$FRONTEND" --env="SYS_CSAT_HOST=csatservice.$FRONTEND" --env="SYS_CSAT_PORT:8883" --env="SYS_CSAT_VERSION=$HOST_VERSION" --env="SYS_USERSERVICE_HOST=userservice.$FRONTEND" --env="SYS_USERSERVICE_VERSION=$HOST_VERSION" --env="SYS_USERSERVICE_PORT=$LB_PORT" --env="LB_PORT=$LB_PORT" --env="HOST_EVENT_CONSUME_TYPE=$EVENT_CONSUME_TYPE" --env="HOST_EVENT_QUEUE=$EVENT_QUEUE" --env="HOST_HTTP_EVENT_QUEUE=$HTTP_EVENT_QUEUE" --expose=8807/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name httpprogrammingapi httpprogrammingapi:$VERSION_TAG node /usr/local/src/httpprogrammingapi/app.js;
;;
   "sipuserendpointservice")
#23
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"sipuserendpointservice:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"sipuserendpointservice:"$VERSION_TAG "sipuserendpointservice:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"sipuserendpointservice:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-SIPUserEndpointService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-SIPUserEndpointService.git;
fi

cd DVP-SIPUserEndpointService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "sipuserendpointservice:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/sipuserendpointservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="HOST_SIPUSERENDPOINTSERVICE_PORT=8814" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_LBDATABASE_MYSQL_USER=$LBDATABASE_MYSQL_USER" --env="SYS_LBDATABASE_MYSQL_PASSWORD=$LBDATABASE_MYSQL_PASSWORD" --env="SYS_LBDATABASE_HOST=$LBDATABASE_HOST" --env="SYS_LBDATABASE_TYPE=$LBDATABASE_TYPE" --env="SYS_LBMYSQL_PORT=$LBMYSQL_PORT" --env="SYS_LBDATABASE_MYSQL_DB=$LBDATABASE_MYSQL_DB" --env="VIRTUAL_HOST=sipuserendpointservice.*" --env="LB_FRONTEND=sipuserendpointservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8814/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name sipuserendpointservice sipuserendpointservice:$VERSION_TAG node /usr/local/src/sipuserendpointservice/app.js;
;;
   "clusterconfig")
#24
cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"clusterconfig:"$VERSION_TAG;
 docker tag $REPOSITORY_IPURL":5000"/"clusterconfig:"$VERSION_TAG "clusterconfig:"$VERSION_TAG;
 docker rmi -f $REPOSITORY_IPURL":5000"/"clusterconfig:"$VERSION_TAG;
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-ClusterConfiguration" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-ClusterConfiguration.git;
fi

cd DVP-ClusterConfiguration;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "clusterconfig:"$VERSION_TAG .;
fi
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/clusterconfiguration/config" --env="HOST_CLUSTERCONFIGURATION_PORT=8805" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABAS
