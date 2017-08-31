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

docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro -v /etc/localtime:/etc/localtime:ro --log-opt max-size=10m --restart=always --log-opt max-file=10 jwilder/nginx-proxy

# install services

for index in "${!array[@]}"
do
 #   echo "$index ${array[index]}"


SERVICE=${array[index]}

case "$SERVICE" in
   "dynamicconfigurationgenerator")
#1
cd /usr/src/;
if [ ! -d "DVP-DynamicConfigurationGenerator" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-DynamicConfigurationGenerator.git;
fi
cd DVP-DynamicConfigurationGenerator;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "dynamicconfigurationgenerator:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/dynamicconfigurationgenerator/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_BILLING_ENABLED=$BILLING_ENABLED" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION"  --env="HOST_DYNAMICCONFIGGEN_PORT=8816" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=dynamicconfigurationgenerator.*" --env="LB_FRONTEND=dynamicconfigurationgenerator.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8816/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name dynamicconfigurationgenerator dynamicconfigurationgenerator:$VERSION_TAG node /usr/local/src/dynamicconfigurationgenerator/app.js;
;;

   "resourceservice")
#2
cd /usr/src/;
if [ ! -d "DVP-ResourceService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-ResourceService.git;
fi

cd DVP-ResourceService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "resourceservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/resourceservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_RESOURCESERVICE_PORT=8831" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_DASHBOARD_REDIS_HOST=$DASHBOARD_REDIS_HOST" --env="SYS_DASHBOARD_REDIS_PORT=$DASHBOARD_REDIS_PORT" --env="SYS_DASHBOARD_REDIS_PASSWORD=$DASHBOARD_REDIS_PASSWORD" --env="SYS_REDIS_DB_DASHBOARD=$REDIS_DB_DASHBOARD" --env="VIRTUAL_HOST=resourceservice.*" --env="LB_FRONTEND=resourceservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8831/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name resourceservice resourceservice:$VERSION_TAG node /usr/local/src/resourceservice/app.js;

;;
   "ardsmonitoring")
#3
cd /usr/src/;
if [ ! -d "DVP-ARDSMonitoring" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-ARDSMonitoring.git;
fi

cd DVP-ARDSMonitoring;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "ardsmonitoring:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/ardsmonitoring/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ARDSMONITOR_PORT=8830" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --env="SYS_CDRPROCESSOR_HOST=cdrprocessor.$FRONTEND" --env="SYS_CDRPROCESSOR_PORT=8809" --env="SYS_CDRPROCESSOR_VERSION=$HOST_VERSION" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="SYS_NOTIFICATIONSERVICE_VERSION=$HOST_VERSION" --env="SYS_ARDSLITEROUTINGENGINE_HOST=ardsliteroutingengine.$FRONTEND" --env="SYS_ARDSLITEROUTINGENGINE_PORT=8835" --env="SYS_ARDSLITEROUTINGENGINE_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="VIRTUAL_HOST=ardsmonitoring.*" --env="LB_FRONTEND=ardsmonitoring.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8830/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ardsmonitoring ardsmonitoring:$VERSION_TAG node /usr/local/src/ardsmonitoring/app.js;

;;
   "phonenumbertrunkservice")
#4
cd /usr/src/;
if [ ! -d "DVP-PhoneNumberTrunkService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-PhoneNumberTrunkService.git;
fi

cd DVP-PhoneNumberTrunkService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "phonenumbertrunkservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/phonenumbertrunkservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_PHONENUMBERTRUNKSERVICE_PORT=8818" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="VIRTUAL_HOST=phonenumbertrunkservice.*" --env="LB_FRONTEND=phonenumbertrunkservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8818/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name phonenumbertrunkservice phonenumbertrunkservice:$VERSION_TAG node /usr/local/src/phonenumbertrunkservice/app.js;
;;
 "limithandler")
#5
cd /usr/src/;
if [ ! -d "DVP-LimitHandler" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-LimitHandler.git;
fi

cd DVP-LimitHandler;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "limithandler:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/limithandler/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_LIMITHANDLER_PORT=8815" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="VIRTUAL_HOST=limithandler.*" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="LB_FRONTEND=limithandler.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_VERSION=$HOST_VERSION" --env="SYS_USERSERVICE_HOST=userservice.$FRONTEND" --env="SYS_USERSERVICE_VERSION=$HOST_VERSION" --env="SYS_APPREGISTRY_HOST=appregistry.$FRONTEND" --env="SYS_APPREGISTRY_VERSION=$HOST_VERSION" --expose=8815/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name limithandler limithandler:$VERSION_TAG node /usr/local/src/limithandler/app.js;

;;
   "ardsliteroutingengine")
#6
cd /usr/src/;
if [ ! -d "DVP-ARDSLiteRoutingEngine" ]; then
	git clone -b $GO_VERSION_TAG https://github.com/DuoSoftware/DVP-ARDSLiteRoutingEngine.git;
fi

cd DVP-ARDSLiteRoutingEngine;
IFS='.' read -ra VER <<< "$GO_VERSION_TAG"
docker build --build-arg MAJOR_VER=${VER[0]} -t "ardsliteroutingengine:"$GO_VERSION_TAG .;
#docker build -t "ardsliteroutingengine:latest" .;
cd /usr/src/;
##docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="GO_CONFIG_DIR=/go/src/gopkg.in/DuoSoftware/DVP-ARDSLiteRoutingEngine.v2/ArdsLiteRoutingEngine" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ARDSLITEROUTINGENGINE_ID=$ARDSLITEROUTINGENGINE_ID" --env="HOST_USE_MSG_QUEUE=$ARDS_USE_MSG_QUEUE" --env="SYS_REDIS_DB_LOCATION=$REDIS_DB_LOCATION" --env="HOST_ARDSLITEROUTINGENGINE_PORT=8835" --env="HOST_IP=$HOST_IP"  --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="VIRTUAL_HOST=ardsliteroutingengine.*" --env="LB_FRONTEND=ardsliteroutingengine.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --expose=8835/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ardsliteroutingengine ardsliteroutingengine go run *.go;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$GO_VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="GO_CONFIG_DIR=/go/src/gopkg.in/DuoSoftware/DVP-ARDSLiteRoutingEngine.${VER[0]}/ArdsLiteRoutingEngine" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ARDSLITEROUTINGENGINE_ID=$ARDSLITEROUTINGENGINE_ID" --env="HOST_USE_MSG_QUEUE=$ARDS_USE_MSG_QUEUE" --env="SYS_REDIS_DB_LOCATION=$REDIS_DB_LOCATION" --env="HOST_ARDSLITEROUTINGENGINE_PORT=8835" --env="HOST_IP=$HOST_IP"  --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="VIRTUAL_HOST=ardsliteroutingengine.*" --env="LB_FRONTEND=ardsliteroutingengine.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --expose=8835/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ardsliteroutingengine ardsliteroutingengine:$GO_VERSION_TAG go run *.go;

;;
   "notificationservice")
#7
cd /usr/src/;
if [ ! -d "DVP-NotificationServicee" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-NotificationService.git;
fi

cd DVP-NotificationService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "notificationservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/notificationservice/config" --env="SYS_CRM_ENABLE=$CRM_ENABLE" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_NOTIFICATIONSERVICE_PORT=8833" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_CRMINTEGRATION_HOST=crmintegrations.app.veery.cloud" --env="SYS_CRMINTEGRATION_PORT=8894" --env="SYS_CRMINTEGRATION_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=notificationservice.*" --env="LB_FRONTEND=notificationservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8833/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name notificationservice notificationservice:$VERSION_TAG node /usr/local/src/notificationservice/app.js;

;;
   "engagementservice")
#8
cd /usr/src/;
if [ ! -d "DVP-Engagement" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-Engagement.git;
fi

cd DVP-Engagement;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "engagementservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/engagementservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ENGAGEMENTSERVICE_PORT=8834" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=engagementservice.*" --env="LB_FRONTEND=engagementservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8834/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name engagementservice engagementservice:$VERSION_TAG node /usr/local/src/engagementservice/app.js;

;;
   "campaignmanager")
#9
cd /usr/src/;
if [ ! -d "DVP-CampaignManager" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-CampaignManager.git;
fi

cd DVP-CampaignManager;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "campaignmanager:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/campaignmanager/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CAMPAIGNMANAGER_PORT=8827" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="VIRTUAL_HOST=campaignmanager.*" --env="LB_FRONTEND=campaignmanager.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8827/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name campaignmanager campaignmanager:$VERSION_TAG node /usr/local/src/campaignmanager/app.js;

;;
   "pbxservice")
#10
cd /usr/src/;
if [ ! -d "DVP-PBXService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-PBXService.git;
fi

cd DVP-PBXService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "pbxservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/pbxservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_PBXSERVICE_PORT=8820" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="SYS_SIPUSERSERVICE_HOST=sipuserendpointservice.$FRONTEND" --env="SYS_SIPUSERSERVICE_NODE_CONFIG_DIR=/usr/local/src/sipuserendpointservice/config" --env="SYS_SIPUSERSERVICE_PORT=8814"  --env="SYS_SIPUSERSERVICE_VERSION=$HOST_VERSION" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_NODE_CONFIG_DIR=/usr/local/src/fileservice/config" --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=pbxservice.*" --env="LB_FRONTEND=pbxservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8820/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name pbxservice pbxservice:$VERSION_TAG node /usr/local/src/pbxservice/app.js;

;;
   "callbackservice")
#11
cd /usr/src/;
if [ ! -d "DVP-CallBackService" ]; then
	git clone -b $GO_VERSION_TAG https://github.com/DuoSoftware/DVP-CallBackService.git;
fi

cd DVP-CallBackService;
IFS='.' read -ra VER <<< "$GO_VERSION_TAG"
docker build --build-arg MAJOR_VER=${VER[0]} -t "callbackservice:"$GO_VERSION_TAG .;
#docker build -t "callbackservice:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$GO_VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="GO_CONFIG_DIR=/go/src/gopkg.in/DuoSoftware/DVP-CallBackService.${VER[0]}/CallbackServer" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CALLBACKSERVICE_PORT=8840" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_CAMPAIGNMANAGER_HOST=campaignmanager.$FRONTEND" --env="SYS_CAMPAIGNMANAGER_NODE_CONFIG_DIR=/usr/local/src/campaignmanager/config" --env="SYS_CAMPAIGNMANAGER_PORT=8827" --env="SYS_DIALER_HOST=dialerapi.$FRONTEND" --env="SYS_DIALER_PORT=8836" --env="VIRTUAL_HOST=callbackservice.*" --env="LB_FRONTEND=callbackservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8840/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name callbackservice callbackservice:$GO_VERSION_TAG go run *.go;

;;
   "voxboneapi")
#12
cd /usr/src/;
if [ ! -d "DVP-VoxboneAPI" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-VoxboneAPI.git;
fi

cd DVP-VoxboneAPI;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "voxboneapi:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/voxboneapi/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="VOXBONE_URL=https://sandbox.voxbone.com/ws-voxbone/services/rest" --env="HOST_VOXBONEAPI_PORT=8832" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_PHONENUMBERTRUNKSERVICE_HOST=phonenumbertrunkservice.$FRONTEND" --env="SYS_PHONENUMBERTRUNKSERVICE_NODE_CONFIG_DIR=/usr/local/src/phonenumbertrunkservice/config" --env="SYS_PHONENUMBERTRUNKSERVICE_PORT=8818" --env="SYS_LIMITHANDLER_HOST=limithandler.$FRONTEND" --env="SYS_LIMITHANDLER_NODE_CONFIG_DIR=/usr/local/src/limithandler/config" --env="SYS_LIMITHANDLER_PORT=8815" --env="SYS_BILLINGSERVICE_HOST=billingservice.$FRONTEND" --env="SYS_BILLINGSERVICE_PORT=$LB_PORT" --env="SYS_BILLINGSERVICE_VERSION=$HOST_VERSION" --env="SYS_WALLETSERVICE_HOST=walletservice.$FRONTEND" --env="SYS_WALLETSERVICE_PORT=$LB_PORT" --env="SYS_WALLETSERVICE_VERSION=$HOST_VERSION" --env="VOXBONE_URL=$VOX_URL" --env="VOX_APIKEY=$VOX_KEY" --env="VIRTUAL_HOST=voxboneapi.*" --env="LB_FRONTEND=voxboneapi.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8832/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name voxboneapi voxboneapi:$VERSION_TAG node /usr/local/src/voxboneapi/app.js;

;;
   "ruleservice")
#13
cd /usr/src/;
if [ ! -d "DVP-RuleService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-RuleService.git;
fi

cd DVP-RuleService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "ruleservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/ruleservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_RULESERVICE_PORT=8817" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="VIRTUAL_HOST=ruleservice.*" --env="LB_FRONTEND=ruleservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8817/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ruleservice ruleservice:$VERSION_TAG node /usr/local/src/ruleservice/app.js;

;;
   "conference")
#14
cd /usr/src/;
if [ ! -d "DVP-Conference" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-Conference.git;
fi

cd DVP-Conference;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "conference:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/conference/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="HOST_NAME=conference" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_CONFERENCE_PORT=8821" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="VIRTUAL_HOST=conference.*" --env="LB_FRONTEND=conference.$FRONTEND" --env="LB_PORT=LB_PORT" --expose 8821 --log-opt max-size=10m --log-opt max-file=10 --restart=always --name conference conference:$VERSION_TAG node /usr/local/src/conference/app.js;

;;
   "httpprogrammingapidebug")
#15
cd /usr/src/;
if [ ! -d "DVP-HTTPProgrammingAPIDEBUG" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-HTTPProgrammingAPIDEBUG.git;
fi

cd DVP-HTTPProgrammingAPIDEBUG;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "httpprogrammingapidebug:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/httpprogrammingapidebug/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_HTTPPROGRAMMINGAPIDEBUG_PORT=8825" ---env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_HTTPPROGRAMMINGAPI_HOST=httpprogrammingapi.$FRONTEND" --env="VIRTUAL_HOST=httpprogrammingapidebug.*" --env="LB_FRONTEND=httpprogrammingapidebug.$FRONTEND" --env="LB_PORT=LB_PORT" --expose=8825/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name httpprogrammingapidebug httpprogrammingapidebug:$VERSION_TAG node /usr/local/src/httpprogrammingapidebug/app.js 

;;
   "interactions")
#16
cd /usr/src/;
if [ ! -d "DVP-Interactions" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-Interactions.git;
fi

cd DVP-Interactions;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "interactions:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/interactions/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_INTERACTIONS_PORT=8873" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=interactions.*" --env="LB_FRONTEND=interactions.$FRONTEND" --env="LB_PORT=LB_PORT" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_SIPUSERENDPOINTSERVICE_HOST=sipuserendpointservice.$FRONTEND" --env="SYS_SIPUSERENDPOINTSERVICE_PORT=8814" --env="SYS_SIPUSERENDPOINTSERVICE_VERSION=$HOST_VERSION" --env="SYS_CLUSTERCONFIG_HOST=clusterconfig.$FRONTEND" --env="SYS_CLUSTERCONFIG_PORT=8805" --env="SYS_CLUSTERCONFIG_VERSION=$HOST_VERSION" --expose=8873/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name interactions interactions:$VERSION_TAG node /usr/local/src/interactions/app.js

;;
   "templates")
#17
cd /usr/src/;
if [ ! -d "DVP-Templates" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-Templates.git
fi

cd DVP-Templates;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "templates:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/templates/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_TEMPLATE_PORT=8875" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=templates.*" --env="LB_FRONTEND=templates.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8875/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name templates templates:$VERSION_TAG node /usr/local/src/templates/app.js;

;;
   "ardsliteservice")
#18
cd /usr/src/;
if [ ! -d "DVP-ARDSLiteService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-ARDSLiteService.git;
fi

cd DVP-ARDSLiteService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "ardsliteservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/ardsliteservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ARDSLITESERVICE_PORT=8828" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_ARDSLITEROUTINGENGINE_HOST=ardsliteroutingengine.$FRONTEND" --env="SYS_ARDSLITEROUTINGENGINE_GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-ARDSLiteRoutingEngine/ArdsLiteRoutingEngine" --env="SYS_ARDSLITEROUTINGENGINE_PORT=8835" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=ardsliteservice.*" --env="LB_FRONTEND=ardsliteservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_SCHEDULEWORKER_HOST=scheduleworker.$FRONTEND" --env="SYS_SCHEDULEWORKER_PORT=8852" --env="SYS_SCHEDULEWORKER_VERSION=$HOST_VERSION" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_VERSION=$HOST_VERSION" --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="SYS_ARDSMONITORING_HOST=ardsmonitoring.$FRONTEND" --env="SYS_ARDSMONITORING_PORT=8830" --env="SYS_ARDSMONITORING_VERSION=$HOST_VERSION" --env="HOST_USE_MSG_QUEUE=$ARDS_USE_MSG_QUEUE" --expose=8828/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ardsliteservice ardsliteservice:$VERSION_TAG node /usr/local/src/ardsliteservice/app.js;

;;
   "userservice")
#19
cd /usr/src/;
if [ ! -d "DVP-UserService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-UserService.git;
fi

cd DVP-UserService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "userservice:"$VERSION_TAG .;
cd /usr/src/;
##docker run -d -t --env="NODE_CONFIG_DIR=/usr/local/src/userservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_USERSERVICE_PORT=8842" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="VIRTUAL_HOST=userservice.*" --env="LB_FRONTEND=userservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8842/tcp --restart=always --name userservice userservice node /usr/local/src/userservice/app.js;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env='NODE_CONFIG_DIR=/usr/local/src/userservice/config' --env="HOST_TOKEN=$HOST_TOKEN" --env="ACTIVE_TENANT=$TENANT" --env="HOST_USERSERVICE_PORT=8842" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="VIRTUAL_HOST=userservice.*" --env="LB_FRONTEND=userservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_SIPUSERENDPOINTSERVICE_HOST=sipuserendpointservice.$FRONTEND" --env="SYS_SIPUSERENDPOINTSERVICE_PORT=8814" --env="SYS_SIPUSERENDPOINTSERVICE_VERSION=$HOST_VERSION" --env="SYS_CLUSTERCONFIG_HOST=clusterconfig.$FRONTEND" --env="SYS_CLUSTERCONFIG_PORT=8805" --env="SYS_CLUSTERCONFIG_VERSION=$HOST_VERSION" --env="FACEBOOK_CLIENT_SECRET=$FACEBOOK_PWD" --env="FOURSQUARE_CLIENT_SECRET=$FOURSQUARE_PWD" --env="GOOGLE_CLIENT_SECRET=$GOOGLE_PWD" --env="GITHUB_CLIENT_SECRET=$GITHUB_PWD" --env="INSTAGRAM_CLIENT_SECRET=$INSTAGRAM_PWD" --env="LINKEDIN_CLIENT_SECRET=$LINKEDIN_PWD" --env="TWITCH_CLIENT_SECRET=$TWITCH_PWD" --env="MICROSOFT_CLIENT_SECRET=$WINDOWS_PWD" --env="YAHOO_CLIENT_SECRET=$YAHOO_PWD" --env="BITBUCKET_CLIENT_SECRET=$BITBUCKET_PWD" --env="SPOTIFY_CLIENT_SECRET=$SPOTIFY_PWD" --env="TWITTER_CLIENT_KEY=$TWITTER_KEY" --env="TWITTER_CLIENT_SECRET=$TWITTER_PWD" --env="LOGIN_VERIFICATION_REQUIRE=$LOGIN_VERIFICATION" --env="SIGNUP_VERIFICATION_REQUIRE=$SIGNUP_VERIFICATION" --env="GOOGLE_RECAPTCHA_KEY=$GOOGLE_RECAPTCHA_KEY" --env="SYS_APP_UI_HOST=$APP_UI_HOST" --env="SYS_BILLINGSERVICE_HOST=billingservice.$FRONTEND" --env="SYS_BILLINGSERVICE_PORT=$LB_PORT" --env="SYS_BILLINGSERVICE_VERSION=$HOST_VERSION" --expose=8842/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name userservice userservice:$VERSION_TAG node /usr/local/src/userservice/app.js

;;

   "monitorrestapi")
#20
cd /usr/src/;
if [ ! -d "DVP-MonitorRestAPI" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-MonitorRestAPI.git;
fi

cd DVP-MonitorRestAPI;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "monitorrestapi:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/monitorrestapi/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_MONITORRESTAPI_PORT=8823" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="VIRTUAL_HOST=monitorrestapi.*" --env="LB_FRONTEND=monitorrestapi.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8823/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name monitorrestapi monitorrestapi:$VERSION_TAG node /usr/local/src/monitorrestapi/app.js;

;;
   "httpprogrammingapi")
#21-
cd /usr/src/;
if [ ! -d "DVP-HTTPProgrammingAPI" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-HTTPProgrammingAPI.git;
fi

cd DVP-HTTPProgrammingAPI;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "httpprogrammingapi:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/httpprogrammingapi/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_FREESWITCH_HOST=$FREESWITCH_HOST"  --env="SYS_EVENTSOCKET_PORT=$EVENTSOCKET_PORT" --env="FS_PASSWORD=$FREESWITCH_EVENTSOCKET_PASSWORD" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="HOST_HTTPPROGRAMMINGAPI_PORT=8807" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_NODE_CONFIG_DIR=/usr/local/src/fileservice/config" --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --env="SYS_DOWNLOAD_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_DOWNLOAD_FILESERVICE_PORT=8812" --env="SYS_DOWNLOAD_FILESERVICE_VERSION=$HOST_VERSION" --env="SYS_RULESERVICE_HOST=$RULESERVICE_HOST" --env="SYS_RULESERVICE_PORT=8817" --env="SYS_RULESERVICE_VERSION=ruleservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_NODE_CONFIG_DIR=/usr/local/src/ardsliteservice/config" --env="SYS_ARDSLITESERVICE_PORT=8828" --env="SYS_QUEUEMUSIC_HOST=queuemusic.$FRONTEND" --env="SYS_QUEUEMUSIC_PORT=8842" --env="SYS_QUEUEMUSIC_VERSION=$HOST_VERSION" --env="SYS_INTERACTION_HOST=interactions.$FRONTEND" --env="SYS_INTERACTION_PORT=8873" --env="SYS_INTERACTION_VERSION=$HOST_VERSION" --env="SYS_TICKET_HOST=liteticket.$FRONTEND" --env="SYS_TICKET_PORT=8872" --env="SYS_TICKET_VERSION=1.0.0.0" --env="VIRTUAL_HOST=httpprogrammingapi.*" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="LB_FRONTEND=httpprogrammingapi.$FRONTEND" --env="SYS_CSAT_HOST=csatservice.$FRONTEND" --env="SYS_CSAT_PORT:8883" --env="SYS_CSAT_VERSION=$HOST_VERSION" --env="SYS_USERSERVICE_HOST=userservice.$FRONTEND" --env="SYS_USERSERVICE_VERSION=$HOST_VERSION" --env="SYS_USERSERVICE_PORT=$LB_PORT" --env="LB_PORT=$LB_PORT" --expose=8807/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name httpprogrammingapi httpprogrammingapi:$VERSION_TAG node /usr/local/src/httpprogrammingapi/app.js;
 
;;
   "sipuserendpointservice")
#23
cd /usr/src/;
if [ ! -d "DVP-SIPUserEndpointService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-SIPUserEndpointService.git;
fi

cd DVP-SIPUserEndpointService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "sipuserendpointservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/sipuserendpointservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="HOST_SIPUSERENDPOINTSERVICE_PORT=8814" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_LBDATABASE_MYSQL_USER=$LBDATABASE_MYSQL_USER" --env="SYS_LBDATABASE_MYSQL_PASSWORD=$LBDATABASE_MYSQL_PASSWORD" --env="SYS_LBDATABASE_HOST=$LBDATABASE_HOST" --env="SYS_LBDATABASE_TYPE=$LBDATABASE_TYPE" --env="SYS_LBMYSQL_PORT=$LBMYSQL_PORT" --env="SYS_LBDATABASE_MYSQL_DB=$LBDATABASE_MYSQL_DB" --env="VIRTUAL_HOST=sipuserendpointservice.*" --env="LB_FRONTEND=sipuserendpointservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8814/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name sipuserendpointservice sipuserendpointservice:$VERSION_TAG node /usr/local/src/sipuserendpointservice/app.js;

;;
   "clusterconfig")
#24
cd /usr/src/;
if [ ! -d "DVP-ClusterConfiguration" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-ClusterConfiguration.git;
fi

cd DVP-ClusterConfiguration;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "clusterconfig:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/clusterconfiguration/config" --env="HOST_CLUSTERCONFIGURATION_PORT=8805" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_CONFIG=$REDIS_DB_CONFIG" --env="VIRTUAL_HOST=clusterconfig.*" --env="LB_FRONTEND=clusterconfig.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8805/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name clusterconfig clusterconfig:$VERSION_TAG node /usr/local/src/clusterconfiguration/app.js;

;;
   "eventmonitor")
#25
cd /usr/src/;
if [ ! -d "DVP-EventMonitor" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-EventMonitor.git;
fi

cd DVP-EventMonitor;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "eventmonitor:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/eventmonitor/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_EVENTMONITOR_PORT=8806" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=DuoS123" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_PROCESSEDCDR=$REDIS_DB_PROCESSEDCDR" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="HOST_EVENT_CONSUME_TYPE=$EVENT_CONSUME_TYPE" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_NODE_CONFIG_DIR=/usr/local/src/ardsliteservice/config" --env="SYS_ARDSLITESERVICE_PORT=8828" --env="SYS_ARDSLITESERVICE_VERSION=$HOST_VERSION" --env="SYS_DIALER_HOST=dialerapi.$FRONTEND" --env="SYS_DIALER_GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-DialerAPI/DuoDialer" --env="SYS_DIALER_PORT=8836" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="SYS_INTERACTIONS_HOST=interactions.$FRONTEND" --env="SYS_INTERACTIONS_VERSION=$HOST_VERSION" --env="SYS_FREESWITCH_HOST=$FREESWITCH_HOST" --env="SYS_FREESWITCH_EVENTSOCKET_PASSWORD=$FREESWITCH_EVENTSOCKET_PASSWORD" --env="SYS_XMLRPC_PORT=$XMLRPC_PORT" --env="SYS_EVENTSOCKET_PORT=$EVENTSOCKET_PORT" --env="VIRTUAL_HOST=eventmonitor.*" --env="LB_FRONTEND=eventmonitor.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8806/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name eventmonitor eventmonitor:$VERSION_TAG node /usr/local/src/eventmonitor/app.js;

;;
   "queuemusic")
#26
cd /usr/src/;
if [ ! -d "DVP-QueueMusic" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-QueueMusic.git;
fi

cd DVP-QueueMusic;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "queuemusic:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/queuemusic/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="HOST_NAME=queuemusic" --env="HOST_QUEUEMUSIC_PORT=8843" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=queuemusic.*" --env="LB_FRONTEND=queuemusic.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8843/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name queuemusic queuemusic:$VERSION_TAG node /usr/local/src/queuemusic/app.js;

;;
   "appregistry")
#27
cd /usr/src/;
if [ ! -d "DVP-APPRegistry" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-APPRegistry.git;
fi

cd DVP-APPRegistry;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "appregistry:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/appregistry/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="HOST_APPREGISTRY_PORT=8811" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=appregistry.*" --env="LB_FRONTEND=appregistry.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8811/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name appregistry appregistry:$VERSION_TAG node /usr/local/src/appregistry/app.js;

;;
   "autoattendant")
#28
cd /usr/src/;
if [ ! -d "DVP-AutoAttendant" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-AutoAttendant.git;
fi

cd DVP-AutoAttendant;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "autoattendant:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/autoattendant/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT"  --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_AUTOATTENDANT_PORT=8824" --env="VIRTUAL_HOST=autoattendant.*" --env="LB_FRONTEND=autoattendant.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8824/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name autoattendant autoattendant:$VERSION_TAG node /usr/local/src/autoattendant/app.js;

;;
   "dialerapi")
#29
cd /usr/src/;
if [ ! -d "DVP-DialerAPI" ]; then
	git clone -b $GO_VERSION_TAG https://github.com/DuoSoftware/DVP-DialerAPI.git;
fi

cd DVP-DialerAPI;
IFS='.' read -ra VER <<< "$GO_VERSION_TAG"
docker build --build-arg MAJOR_VER=${VER[0]} -t "dialerapi:"$GO_VERSION_TAG .;
#docker build -t "dialerapi:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$GO_VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="GO_CONFIG_DIR=/go/src/gopkg.in/DuoSoftware/DVP-DialerAPI.${VER[0]}/DuoDialer" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_DIALER=$REDIS_DB_DIALER" --env="SYS_DIALER_ID=Dialer2" --env="HOST_DIALER_PORT=8836" --env="SYS_DIALER_CAMP_LIMIT=30" --env="SYS_RULESERVICE_HOST=ruleservice.$FRONTEND" --env="SYS_RULESERVICE_PORT=8817" --env="SYS_CAMPAIGNMANAGER_HOST=campaignmanager.$FRONTEND" --env="SYS_CAMPAIGNMANAGER_PORT=8827" --env="SYS_LIMITHANDLER_HOST=limithandler.$FRONTEND" --env="SYS_LIMITHANDLER_PORT=8815" --env="SYS_CALLBACKSERVICE_HOST=callbackservice.$FRONTEND" --env="SYS_CALLBACKSERVICE_PORT=8840" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_PORT=8828" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="SYS_CLUSTERCONFIGURATION_HOST=clusterconfig.$FRONTEND" --env="SYS_CLUSTERCONFIGURATION_PORT=8805" --env="SYS_FREESWITCH_HOST=$FREESWITCH_HOST" --env="SYS_FS_XMLRPC_PORT=$XMLRPC_PORT" --env="VIRTUAL_HOST=dialerapi.*" --env="LB_FRONTEND=dialerapi.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8836/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name dialerapi dialerapi:$GO_VERSION_TAG go run *.go;

;;
   "dashboard")
#30
cd /usr/src/;
if [ ! -d "DVP-DashBoard" ]; then
	git clone -b $GO_VERSION_TAG https://github.com/DuoSoftware/DVP-DashBoard.git
fi

cd DVP-DashBoard;
IFS='.' read -ra VER <<< "$GO_VERSION_TAG"
docker build --build-arg MAJOR_VER=${VER[0]} -t "dashboard:"$GO_VERSION_TAG .;
#docker build -t "dashboard:latest" .;
cd /usr/src/;
#docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-DashBoard/DashBoard" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DASHBOARD_REDIS_HOST=$DASHBOARD_REDIS_HOST" --env="SYS_DASHBOARD_REDIS_PORT=$DASHBOARD_REDIS_PORT" --env="SYS_DASHBOARD_REDIS_PASSWORD=$DASHBOARD_REDIS_PASSWORD" --env="SYS_DASHBOARDSERVICE_HOST=dashboardservice.$FRONTEND" --env="SYS_DASHBOARDSERVICE_PORT=8874" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_DASHBOARD_PORT=8841" --env="HOST_DASHBOARD_CACHE=$DASHBOARD_CACHE_TYPE" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_DB_DASHBOARD=$REDIS_DB_DASHBOARD" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_STATSD_HOST=$STATSD_HOST" --env="SYS_STATSD_PORT=$STATSD_PORT" --env="VIRTUAL_HOST=dashboard.*" --env="LB_FRONTEND=dashboard.$FRONTEND" --env="LB_PORT=80" --env="SYS_DASHBOARDSERVICE_HOST=dashboardservice.$FRONTEND" --env="SYS_DASHBOARDSERVICE_PORT=8883" --expose=8841/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name dashboard dashboard go run *.go
#docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-DashBoard/DashBoard" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DASHBOARD_REDIS_HOST=$DASHBOARD_REDIS_HOST" --env="SYS_DASHBOARD_REDIS_PORT=$DASHBOARD_REDIS_PORT" --env="SYS_DASHBOARD_REDIS_PASSWORD=$DASHBOARD_REDIS_PASSWORD" --env="SYS_DASHBOARDSERVICE_HOST=dashboardservice.$FRONTEND" --env="SYS_DASHBOARDSERVICE_PORT=8874" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_DASHBOARD_PORT=8841" --env="HOST_DASHBOARD_CACHE=$DASHBOARD_CACHE_TYPE" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_DB_DASHBOARD=$REDIS_DB_DASHBOARD" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_STATSD_HOST=$STATSD_HOST" --env="SYS_STATSD_PORT=$STATSD_PORT" --env="VIRTUAL_HOST=dashboard.*" --env="LB_FRONTEND=dashboard.$FRONTEND" --env="LB_PORT=80" --env="SYS_DASHBOARDSERVICE_HOST=dashboardservice.$FRONTEND" --env="SYS_DASHBOARDSERVICE_PORT=8883" --expose=8841/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name dashboard dashboard go run *.go
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$GO_VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="GO_CONFIG_DIR=/go/src/gopkg.in/DuoSoftware/DVP-DashBoard.${VER[0]}/DashBoard" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DASHBOARD_REDIS_HOST=$DASHBOARD_REDIS_HOST" --env="SYS_DASHBOARD_REDIS_PORT=$DASHBOARD_REDIS_PORT" --env="SYS_DASHBOARD_REDIS_PASSWORD=$DASHBOARD_REDIS_PASSWORD" --env="SYS_DASHBOARDSERVICE_HOST=dashboardservice.$FRONTEND" --env="SYS_DASHBOARDSERVICE_PORT=8874" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_DASHBOARD_PORT=8841" --env="HOST_DASHBOARD_CACHE=$DASHBOARD_CACHE_TYPE" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_DASHBOARD=$REDIS_DB_DASHBOARD" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_STATSD_HOST=$STATSD_HOST" --env="SYS_STATSD_PORT=$STATSD_PORT" --env="VIRTUAL_HOST=dashboard.*" --env="LB_FRONTEND=dashboard.$FRONTEND" --env="LB_PORT=80" --env="SYS_DASHBOARDSERVICE_HOST=dashboardservice.$FRONTEND" --env="SYS_DASHBOARDSERVICE_PORT=8883" --expose=8841/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name dashboard dashboard:$GO_VERSION_TAG go run *.go

;;
   "cdrprocessor")
#31
cd /usr/src/;
if [ ! -d "DVP-CDRProcessor" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-CDRProcessor.git;
fi

cd DVP-CDRProcessor;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "cdrprocessor:"$VERSION_TAG .;
cd /usr/src/;

docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/cdrprocessor/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CDRPROCESSOR_PORT=8809" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_PORT=$LB_PORT" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=cdrprocessor.*" --env="LB_FRONTEND=cdrprocessor.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8809/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name cdrprocessor cdrprocessor:$VERSION_TAG node --expose-gc /usr/local/src/cdrprocessor/app.js;
#docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/cdrprocessor/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CDRPROCESSOR_PORT=8809" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_PORT=$LB_PORT" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=cdrprocessor.*" --env="LB_FRONTEND=cdrprocessor.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8809/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name cdrprocessor cdrprocessor:$VERSION_TAG node /usr/local/src/cdrprocessor/app.js;


;;
   "eventservice")
#32
cd /usr/src/;
if [ ! -d "DVP-EventService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-EventService.git
fi

cd DVP-EventService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "eventservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env='NODE_CONFIG_DIR=/usr/local/src/eventservice/config' --env="HOST_EVENTSERVICE_PORT=8822" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="VIRTUAL_HOST=eventservice.*" --env="LB_FRONTEND=eventservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8822/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name eventservice eventservice:$VERSION_TAG node /usr/local/src/eventservice/app.js
#docker run -d -t

;;
   "liteticket")
#33
cd /usr/src/;
if [ ! -d "DVP-LiteTicket" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-LiteTicket.git
fi

cd DVP-LiteTicket;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "liteticket:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/liteticket/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_LITETICKET_PORT=8872" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_DASHBOARD_REDIS_HOST=$DASHBOARD_REDIS_HOST" --env="SYS_DASHBOARD_REDIS_PORT=$DASHBOARD_REDIS_PORT" --env="SYS_DASHBOARD_REDIS_PASSWORD=$DASHBOARD_REDIS_PASSWORD" --env="SYS_REDIS_DB_DASHBOARD=$REDIS_DB_DASHBOARD" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="VIRTUAL_HOST=liteticket.*" --env="LB_FRONTEND=liteticket.$FRONTEND"  --env="LB_PORT=$LB_PORT" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND"  --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_SIPUSERENDPOINTSERVICE_HOST=sipuserendpointservice.$FRONTEND"  --env="SYS_SIPUSERENDPOINTSERVICE_PORT=8814" --env="SYS_SIPUSERENDPOINTSERVICE_VERSION=$HOST_VERSION" --env="SYS_CLUSTERCONFIG_HOST=clusterconfig.$FRONTEND"  --env="SYS_CLUSTERCONFIG_PORT=8805" --env="SYS_CLUSTERCONFIG_VERSION=$HOST_VERSION" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND"  --env="SYS_ARDSLITESERVICE_PORT=8828" --env="SYS_ARDSLITESERVICE_VERSION=$HOST_VERSION" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND"  --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="SYS_NOTIFICATIONSERVICE_VERSION=$HOST_VERSION" --env="SYS_SCHEDULEWORKER_HOST=scheduleworker.$FRONTEND"  --env="SYS_SCHEDULEWORKER_PORT=8852" --env="SYS_SCHEDULEWORKER_VERSION=$HOST_VERSION" --env="SYS_INTERACTIONS_HOST=interactions.$FRONTEND" --env="SYS_INTERACTIONS_VERSION=$HOST_VERSION" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND"  --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --expose=8872/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name liteticket liteticket:$VERSION_TAG node --expose-gc /usr/local/src/liteticket/app.js
#docker run -d -t

;;
   "httpprogrammingmonitorapi")
#34
cd /usr/src/;
if [ ! -d "DVP-HTTPProgrammingMonitorAPI" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-HTTPProgrammingMonitorAPI.git;
fi

cd DVP-HTTPProgrammingMonitorAPI;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "httpprogrammingmonitorapi:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env='NODE_CONFIG_DIR=/usr/local/src/httpprogrammingmonitorapi/config' --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="VIRTUAL_HOST=httpprogrammingmonitorapi.*" --env="LB_FRONTEND=httpprogrammingmonitorapi.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8813/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name httpprogrammingmonitorapi httpprogrammingmonitorapi:$VERSION_TAG node /usr/local/src/httpprogrammingmonitorapi/app.js
#docker run -d -t
;;

   "scheduleworker")
 #35
cd /usr/src/;
if [ ! -d "DVP-ScheduleWorker" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-ScheduleWorker.git
fi
cd DVP-ScheduleWorker;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "scheduleworker:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/scheduleworker/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_SCHEDULEWORKER_PORT=8852" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="VIRTUAL_HOST=scheduleworker.*" --env="LB_FRONTEND=scheduleworker.$FRONTEND"  --env="LB_PORT=$LB_PORT" --expose=8852/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name scheduleworker scheduleworker:$VERSION_TAG node /usr/local/src/scheduleworker/app.js
#docker run -d -t
;;

 "fileservice")
#36
cd /usr/src/;
if [ ! -d "DVP-FileService" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-FileService.git;
fi
cd DVP-FileService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "fileservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro -v $FILE_DIRECTORY_PATH:/usr/local/src/fileservice/upload --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="STORAGE_OPTION=$FILE_STORAGE" --env="NODE_CONFIG_DIR=/usr/local/src/fileservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_FILESERVICE_PORT=8812" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_COUCH_HOST=$COUCH_HOST" --env="SYS_COUCH_PORT=$COUCH_PORT" --env="VIRTUAL_HOST=fileservice.*" --env="LB_FRONTEND=fileservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="CRYPTO_ALGO=$CRYPTO_ALGO" --env="CRYPTO_PASSWORD=$CRYPTO_PASSWORD" --expose=8812/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name fileservice fileservice:$VERSION_TAG node /usr/local/src/fileservice/app.js;
;;

   "cdrgenerator")
#37
cd /usr/src/;
if [ ! -d "DVP-CDRGenerator" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-CDRGenerator.git;
fi

cd DVP-CDRGenerator;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "cdrgenerator:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/cdrgenerator/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CDRGENERATOR_PORT=8859" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_PROCESSCDR=$REDIS_DB_PROCESSCDR" --env="VIRTUAL_HOST=cdrgenerator.*" --env="LB_FRONTEND=cdrgenerator.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8859/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name cdrgenerator cdrgenerator:$VERSION_TAG node /usr/local/src/cdrgenerator/app.js;

;;

 "productivityservice")
#38
cd /usr/src/;
if [ ! -d "DVP-ProductivityService" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-ProductivityService.git;
fi
cd DVP-ProductivityService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "productivityservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/productivityservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_PRODUCTIVITYSERVICE_PORT=8876" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_DASHBOARD=$REDIS_DB_DASHBOARD" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="VIRTUAL_HOST=productivityservice.*" --env="LB_FRONTEND=productivityservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8876/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name productivityservice productivityservice:$VERSION_TAG node /usr/local/src/productivityservice/app.js;
;;

 "mailreceiver")
#39
cd /usr/src/;
if [ ! -d "DVP-MailReceiver" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-MailReceiver.git;
fi
cd DVP-MailReceiver;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "mailreceiver:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/mailreceiver/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_MAILRECEIVER_PORT=8877" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_ENABLE_SMTPLISTNER=true" --env="HOST_ENABLE_SMTPSENDER=true" --env="HOST_ENABLE_SMSSENDER=true" --env="HOST_ENABLE_IMAPLISTNER=true" --env="HOST_NAME=mailreceiver.$FRONTEND" --env="SYS_SERVER_ID=" --env="SYS_CALLBACK_OPTION=GET" --env="SYS_REQUEST_TYPE=CALL" --env="SYS_SERVER_ID=2" --env="SYS_RESOURCE_TYPE=cluster" --env="SYS_EMAIL_QUEUE_NAME=EMAILOUT" --env="SYS_SMS_QUEUE_NAME=SMSOUT" --env="SYS_SMTP_LISTNER=true" --env="SYS_SMTP_SENDER=true" --env="SYS_SMS_SENDER=true" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD" --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_SMSSERVER_HOST=$SMS_SERVER" --env="SYS_SMSSERVER_PORT=$SMS_PORT" --env="SYS_SMSSERVER_PASSWORD=$SMS_PASSWORD" --env="SYS_SMSSERVER_USER=$SMS_USER" --env="VIRTUAL_HOST=mailreceiver.*" --env="LB_FRONTEND=mailreceiver.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="IMAP_USER_NAME=duodemouser@gmail.com" --env="IMAP_PASSWORD=DuoS123456" --env="IMAP_HOST=imap.gmail.com" --env="IMAP_PORT=993" --env="IMAP_SECURITY=true" --env="IMAP_MAILBOX=INBOX" --env="IMAP_SEEN=true" --env="IMAP_COMPANY=103" --env="IMAP_TENAT=1" --env="IMAP_FETCH=true" --env="SYS_SMTP_HOST=$SMTP_HOST" --env="SYS_SMTP_PORT=$SMTP_PORT" --env="SYS_SMTP_USER=$SMTP_USER" --env="SYS_SMTP_PASSWORD=$SMTP_PASSWORD" --env="SYS_RESOURCESERVICE_HOST=resourceservic.$FRONTEND" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --env="SYS_SCHEDULEWORKER_HOST=scheduleworker.$FRONTEND" --env="SYS_SCHEDULEWORKER_VERSION=$HOST_VERSION" --env="SYS_LITETICKET_HOST=liteticket.$FRONTEND" --env="SYS_LITETICKET_VERSION=$HOST_VERSION" --env="SYS_INTERACTIONS_HOST=interactions.$FRONTEND" --env="SYS_INTERACTIONS_VERSION=$HOST_VERSION" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_VERSION=$HOST_VERSION" --expose=8877/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name mailreceiver mailreceiver:$VERSION_TAG node /usr/local/src/mailreceiver/app.js;
;;

 "socialconnector")
#40
cd /usr/src/;
if [ ! -d "DVP-SocialConnector" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-SocialConnector.git;
fi
cd DVP-SocialConnector;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "socialconnector:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/socialconnector/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_SOCIALCONNECTOR_PORT=8878" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_SMSSERVER_HOST=$SMS_SERVER" --env="SYS_SMSSERVER_PORT=$SMS_PORT" --env="SYS_SMSSERVER_PASSWORD=$SMS_PASSWORD" --env="SYS_SMSSERVER_USER=$SMS_USER" --env="SYS_SMPP_HOST=$SMTP_HOST" --env="SYS_SMPP_PORT=$SMTP_PORT" --env="SYS_SMPP_PASSWORD=$SMTP_PASSWORD" --env="SYS_SMPP_USER=$SMTP_USER" --env="SMS_QUEUE_NAME=$SMS_QUEUE" --env="SMS_MODE=$SMS_MODE" --env="TWITTER_QUEUE_NAME=$TWITTER_QUEUE" --env="FACEBOOK_QUEUE_NAME=$FACEBOOK_QUEUE" --env="" --env="VIRTUAL_HOST=socialconnector.*" --env="LB_FRONTEND=socialconnector.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_INTERACTIONS_HOST=interactions.$FRONTEND" --env="SYS_INTERACTIONS_VERSION=$HOST_VERSION" --env="SYS_SCHEDULEWORKER_HOST=scheduleworker.$FRONTEND" --env="SYS_SCHEDULEWORKER_VERSION=$HOST_VERSION" --env="SYS_LITETICKET_HOST=liteticket.$FRONTEND" --env="SYS_LITETICKET_VERSION=$HOST_VERSION" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_VERSION=$HOST_VERSION" --env="SYS_FACEBOOK_URL=https://graph.facebook.com/" --expose=8878/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name socialconnector socialconnector:$VERSION_TAG node /usr/local/src/socialconnector/app.js;
#--env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_INTERACTIONS_HOST=interactions.#FRONTEND" --env="SYS_INTERACTIONS_VERSION=$HOST_VERSION" --env="SYS_SCHEDULEWORKER_HOST=scheduleworker.$FRONTEND" --env="SYS_SCHEDULEWORKER_VERSION=$HOST_VERSION" --env="SYS_LITETICKET_HOST=liteticket.$FRONTEND" --env="SYS_LITETICKET_VERSION=$HOST_VERSION" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_VERSION=$HOST_VERSION" --env="SYS_FACEBOOK_URL=https://graph.facebook.com/v2.7/"SMS_QUEUE_NAME
#--env="SYS_RESOURCESERVICE_PORT=" --env="SYS_INTERACTIONS_PORT=" --env"SYS_SCHEDULEWORKER_PORT=" --env="SYS_LITETICKET_PORT=" --env="SYS_ARDSLITESERVICE_PORT=" 
;;

 "todolistservice")
#41
cd /usr/src/;
if [ ! -d "DVP-ToDoListService" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-ToDoListService.git;
fi
cd DVP-ToDoListService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "todolistservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/todolistservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_TODOLISTSERVICE_PORT=8879" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_NAME=todolistservice.$FRONTEND" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=todolistservice.*" --env="LB_FRONTEND=todolistservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_SCHEDULEWORKER_HOST=scheduleworker.$FRONTEND" --env="SYS_SCHEDULEWORKER_VERSION=$HOST_VERSION" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_VERSION=$HOST_VERSION" --expose=8879/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name todolistservice todolistservice:$VERSION_TAG node /usr/local/src/todolistservice/app.js;
;;

 "walletservice")
#42
cd /usr/src/;
if [ ! -d "DVP-Wallet" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-Wallet.git;
fi
cd DVP-Wallet;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "walletservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/walletservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_WALLETSERVICE_PORT=8880" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_KEY=" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="VIRTUAL_HOST=walletservice.*" --env="LB_FRONTEND=walletservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_LIMITSERVICE_HOST=limithandler.$FRONTEND" --env="SYS_LIMITSERVICE_VERSION=$HOST_VERSION" --env="SYS_PHONENUMBERTRUNK_HOST=phonenumbertrunkservice.$FRONTEND" --env="SYS_PHONENUMBERTRUNK_VERSION=$HOST_VERSION" --env="SYS_VOXBONE_URL=https://sandbox.voxbone.com/ws-voxbone/services/rest" --expose=8880/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name walletservice walletservice:$VERSION_TAG node /usr/local/src/walletservice/app.js;
;;

 "billingservice")
#43
cd /usr/src/;
if [ ! -d "DVP-Billing" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-Billing.git;
fi
cd DVP-Billing;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "billingservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/billingservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_BILLINGSERVICE_PORT=8881" --env="BILLING_SCHEDULE_FREQUENCY=$BILLING_SCHEDULE_FREQUENCY" --env="BILLING_SCHEDULE_TRIES=$BILLING_SCHEDULE_TRIES" --env="HOST_USERBILLING_ENABLED=$USERBILLING_ENABLED" --env="HOST_TENANTBILLING_ENABLED=$TENANTBILLING_ENABLED" --env="HOST_TENANT_NAME=$TENANT_NAME" --env="BILLING_DATE=$BILLING_DATE" --env="BILLING_EMAIL_WARNING_ACTIVATION=$BILLING_EMAIL_WARNING" --env="BILLING_SMS_WARNING_ACTIVATION=$BILLING_SMS_WARNING" --env="BILLING_CALL_WARNING_ACTIVATION=$BILLING_CALL_WARNING" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="VIRTUAL_HOST=billingservice.*" --env="LB_FRONTEND=billingservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_USERSERVICE_HOST=userservice.$FRONTEND" --env="SYS_USERSERVICE_VERSION=$HOST_VERSION" --env="SYS_WALLETSERVICE_HOST=$WALLETSERVICE_HOST:$WALLERTSERVICE_PORT" --env="SYS_WALLETSERVICE_VERSION=$HOST_VERSION" --expose=8881/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name billingservice billingservice:$VERSION_TAG node /usr/local/src/billingservice/app.js;
;;


 "integrationapi")
#44
cd /usr/src/;
if [ ! -d "DVP-IntegrationAPI" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-IntegrationAPI.git;
fi
cd DVP-IntegrationAPI;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "integrationapi:"$VERSION_TAG .;
cd /usr/src/;
#docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/integrationapi/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_INTEGRATIONAPI_PORT=8882" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=integrationapi.*" --env="LB_FRONTEND=integrationapi.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8882/tcp -p 4334:4334 --log-opt max-size=10m --log-opt max-file=10 --restart=always --name integrationapi integrationapi:$VERSION_TAG node /usr/local/src/integrationapi/app.js;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/integrationapi/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_INTEGRATIONAPI_PORT=8882" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_USERSERVICE_HOST=userservice.$FRONTEND" --env="SYS_USERSERVICE_VERSION=$HOST_VERSION" --env="SYS_USERSERVICE_PORT=$LB_PORT" --env="VIRTUAL_HOST=integrationapi.*" --env="LB_FRONTEND=integrationapi.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8882/tcp -p 8882:8882 --log-opt max-size=10m --log-opt max-file=10 --restart=always --name integrationapi integrationapi:$VERSION_TAG node /usr/local/src/integrationapi/app.js;
;;

 "dashboardservice")
#45
cd /usr/src/;
if [ ! -d "DVP-DashBoardService" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-DashBoardService.git;
fi
cd DVP-DashBoardService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "dashboardservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/dashboardservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_DASHBOARDSERVICE_PORT=8883" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_REDIS_DB_DASHBOARD=$REDIS_DB_DASHBOARD" --env="SYS_REDIS_DB_ARDS=$REDIS_DB_ARDS" --env="SYS_DASHBOARD_REDIS_HOST=$DASHBOARD_REDIS_HOST" --env="SYS_DASHBOARD_REDIS_PORT=$DASHBOARD_REDIS_PORT" --env="SYS_DASHBOARD_REDIS_PASSWORD=$DASHBOARD_REDIS_PASSWORD" --env="VIRTUAL_HOST=dashboardservice.*" --env="LB_FRONTEND=dashboardservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_STATSD_HOST=$STATSD_HOST" --env="SSYS_STATSD_PORT=$STATSD_PORT" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="SYS_NOTIFICATIONSERVICE_VERSION=$HOST_VERSION" --expose=8883/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name dashboardservice dashboardservice:$VERSION_TAG node /usr/local/src/dashboardservice/app.js;
;;


 "qamodule")
#46
cd /usr/src/;
if [ ! -d "DVP-QAModule" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-QAModule.git;
fi
cd DVP-QAModule;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "qamodule:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/qamodule/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_QAMODULE_PORT=8884" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=qamodule.*" --env="LB_FRONTEND=qamodule.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8884/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name qamodule qamodule:$VERSION_TAG node /usr/local/src/qamodule/app.js;
;;

 "csatservice")
#47
cd /usr/src/;
if [ ! -d "DVP-CSATService" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-CSATService.git;
fi
cd DVP-CSATService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "csatservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/csatservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CSATSERVICE_PORT=8885" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_NAME=csatservice" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION"  --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=csatservice.*" --env="LB_FRONTEND=csatservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8885/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name csatservice csatservice:$VERSION_TAG node /usr/local/src/csatservice/app.js;
;;

 "diameterrelay")
#48
cd /usr/src/;
if [ ! -d "DVP-DiameterRelay" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-DiameterRelay.git;
fi
cd DVP-DiameterRelay;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "diameterrelay:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/diameterrelay/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_DIAMETERRELAY_PORT=8886" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_NAME=diameterrelay" --env="VIRTUAL_HOST=diameterrelay.*" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_DIAMETERSERVER_HOST=diameterserver.$FRONTEND" --env="SYS_DIAMETERSERVER_PORT=$DIAMETER_SERVER_PORT" --env="SYS_DIAMETERSERVER_VERSION=$HOST_VERSION" --env="LB_FRONTEND=diameterrelay.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8886/tcp -p 8886:8886 --log-opt max-size=10m --log-opt max-file=10 --restart=always --name diameterrelay diameterrelay:$VERSION_TAG node /usr/local/src/diameterrelay/app.js;
;;


 "diameterclient")
#49
cd /usr/src/;
if [ ! -d "DVP-DiameterClient" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-DiameterClient.git;
fi
cd DVP-DiameterClient;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "diameterclient:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/diameterclient/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_DIAMETERCLIENT_PORT=8887" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_NAME=diameterclient" --env="VIRTUAL_HOST=diameterclient.*" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_USERSERVICE_HOST=userservice.$FRONTEND" --env="SYS_USERSERVICE_VERSION=$HOST_VERSION" --env="SYS_USERSERVICE_PORT=$LB_PORT" --env="SYS_WALLETSERVICE_HOST=walletservice.$FRONTEND" --env="SYS_WALLETSERVICE_PORT=$LB_PORT" --env="SYS_WALLETSERVICE_VERSION=$HOST_VERSION" --env="SYS_DIAMETERRELAY_HOST=diameterrelay.$FRONTEND" --env="SYS_DIAMETERRELAY_PORT=$DIAMETER_RELAY_PORT" --env="LB_FRONTEND=diameterclient.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8887/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name diameterclient diameterclient:$VERSION_TAG node /usr/local/src/diameterclient/app.js;
;;

 "ipmessagingservice")
#50
cd /usr/src/;
if [ ! -d "DVP-IPMessagingService" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-IPMessagingService.git;
fi
cd DVP-IPMessagingService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "ipmessagingservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/ipmessagingservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_IPMESSANGERSERVICE_PORT=8887" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_NAME=ipmessagingservice.$FRONTEND" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=ipmessagingservice.*" --env="LB_FRONTEND=ipmessagingservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_INTERACTIONS_HOST=interactions.$FRONTEND" --env="SYS_INTERACTIONS_VERSION=$HOST_VERSION" --env="SYS_INTERACTIONS_PORT=$LB_PORT" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_VERSION=$HOST_VERSION" --env="SYS_ARDSLITESERVICE_PORT=$LB_PORT" --expose=8889/tcp -p 8889:8889 --expose=8890/tcp -p 8890:8890 --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ipmessagingservice ipmessagingservice:$VERSION_TAG node /usr/local/src/ipmessagingservice/app.js;

;;

 "diameterserver")
#51
cd /usr/src/;
if [ ! -d "DVP-DiameterServer" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-DiameterServer.git;
fi
cd DVP-DiameterServer;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "diameterserver:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/diameterserver/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_DIAMETERSERVER_PORT=8891" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="VIRTUAL_HOST=diameterserver.*" --env="LB_FRONTEND=diameterserver.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_USERSERVICE_HOST=userservice.$FRONTEND" --env="SYS_USERSERVICE_VERSION=$HOST_VERSION" --env="SYS_USERSERVICE_PORT=8842" --env="SYS_WALLETSERVICE_HOST=$WALLETSERVICE_HOST:$WALLERTSERVICE_PORT" --env="SYS_WALLETSERVICE_VERSION=$HOST_VERSION" --env="SYS_WALLETSERVICE_PORT=8080" --env="SYS_MONITORRESTAPI_HOST=monitorrestapi.$FRONTEND" --env="SYS_MONITORRESTAPI_VERSION=$HOST_VERSION" --env="SYS_MONITORRESTAPI_PORT=8823" --env="SYS_CARRIERPROVIDER_HOST=carrierprovider.$FRONTEND" -env="SYS_CARRIERPROVIDER_VERSION=$HOST_VERSION" --env"SYS_CARRIERPROVIDER_PORT=8890" --expose=8891/tcp -p 8891:8891 --log-opt max-size=10m --log-opt max-file=10 --restart=always --name diameterserver diameterserver:$VERSION_TAG node /usr/local/src/diameterserver/app.js;
;;

 "skypebot")
#52
cd /usr/src/;
if [ ! -d "DVP-SkypeBot" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-SkypeBot.git;
fi
cd DVP-SkypeBot;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "skypebot:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/skypebot/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_SECRET=$HOST_SECRET" --env="HOST_SKYPEBOT_PORT=8892" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_SECRET=$HOST_SECRET" --env="HOST_COMPANY=$HOST_COMPANY" --env="HOST_TENANT=$TENANT" --env="SYS_EXT_MESSENGER_HOST=externalipmessagingservice.$FRONTEND" --env="SYS_EXT_MESSENGER_PORT=8890" --env="SYS_EXT_MESSENGER_VERSION=$HOST_VERSION" --env="SYS_CSAT_HOST=csatservice.$FRONTEND" --env="SYS_CSAT_PORT=$LB_PORT" --env="SYS_CSAT_VERSION=$HOST_VERSION" --env="COMPANY_NAME=$COMPANY_NAME" --env="BOT_APP_ID=$SKYPE_BOT_APP_ID" --env="BOT_APP_PASSWORD=$SKYPE_BOT_APP_PASSWORD" --expose=8892/tcp -p 8892:8892 --log-opt max-size=10m --log-opt max-file=10 --restart=always --name skypebot skypebot:$VERSION_TAG node /usr/local/src/skypebot/app.js;
;;

 "contacts")
#53
cd /usr/src/;
if [ ! -d "DVP-Contacts" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-Contacts.git;
fi
cd DVP-Contacts;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "contacts:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/contacts/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CONTACTS_PORT=8893" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=contacts.*" --env="LB_FRONTEND=contacts.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8893/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name contacts contacts:$VERSION_TAG node /usr/local/src/contacts/app.js;
;;

  "crmintegrations")
#54
cd /usr/src/;
if [ ! -d "DVP-CRMIntegrations" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-CRMIntegrations.git;
fi

cd DVP-CRMIntegrations;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "crmintegrations:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/crmintegrations/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CRMINTEGRATIONS_PORT=8894" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONITORRESTAPI_HOST=monitorrestapi.app.veery.cloud" --env="SYS_MONITORRESTAPI_PORT=8823" --env="SYS_MONITORRESTAPI_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=crmintegrations.*" --env="LB_FRONTEND=crmintegrations.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8894/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name crmintegrations crmintegrations:$VERSION_TAG node /usr/local/src/crmintegrations/app.js;
;;

 "carrierprovider")
#5
cd /usr/src/;
if [ ! -d "DVP-CarrierProvider" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-CarrierProvider.git;
fi

cd DVP-CarrierProvider;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "carrierprovider:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --expose=8080/tcp -p 8090:8080 --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="VIRTUAL_HOST=carrierprovider.*" --env="LB_FRONTEND=carrierprovider.$FRONTEND" --env="LB_PORT=$LB_PORT" --name carrierprovider carrierprovider:$VERSION_TAG asadmin start-domain -v;
;;

"agentdialerservice")
#45
cd /usr/src/;
if [ ! -d "DVP-AgentDialerService" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-AgentDialerService.git;
fi
cd DVP-AgentDialerService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "agentdialerservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/agentdialerservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_AGENTDIALERSERVICE_PORT=8895" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="VIRTUAL_HOST=agentdialerservice.*" --env="LB_FRONTEND=agentdialerservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8895/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name agentdialerservice agentdialerservice:$VERSION_TAG node /usr/local/src/agentdialerservice/app.js;
;;

"filearchiveservice")
#29
cd /usr/src/;
if [ ! -d "DVP-FileArchiveService" ]; then
	git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-FileArchiveService.git;
fi
cd DVP-FileArchiveService;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "filearchiveservice:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro -v $FILE_DIRECTORY_PATH:/usr/local/src/upload --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-FileArchiveService" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_USERSERVICE_HOST=userservice.$FRONTEND" --env="SYS_USERSERVICE_VERSION=$HOST_VERSION" --log-opt max-size=10m --log-opt max-file=10 --restart=always --name filearchiveservice filearchiveservice go run *.go;
;;

 "smppclient")
#53
cd /usr/src/;
if [ ! -d "DVP-SMPPClient" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-SMPPClient.git;
fi
cd DVP-SMPPClient;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "smppclient:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="512m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/smppclient/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="SYS_SMSSERVER_HOST=$SMS_SERVER" --env="SYS_SMSSERVER_PORT=$SMS_PORT" --env="SYS_SMSSERVER_PASSWORD=$SMS_PASSWORD" --env="SYS_SMSSERVER_USER=$SMS_USER" --env="SMS_NUMBER=$SMS_NUMBER" --env="SMS_QUEUE_NAME=SMS_QUEUE" --env="SYS_SMPP_HOST=$SMPP_HOST" --env="SYS_SMPP_PORT=$SMPP_PORT" --env="SYS_SMPP_PASSWORD=$SMPP_PASSWORD" --env="SYS_SMPP_USER=$SMPP_USER" --env="SMS_QUEUE_NAME=$SMS_QUEUE" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_INTERACTIONS_HOST=interactions.$FRONTEND" --env="SYS_INTERACTIONS_PORT=8873" --env="SYS_INTERACTIONS_VERSION=$HOST_VERSION" --env="SYS_SCHEDULEWORKER_HOST=scheduleworker.$FRONTEND" --env="SYS_SCHEDULEWORKER_PORT=8852" --env="SYS_SCHEDULEWORKER_VERSION=$HOST_VERSION" --env="SYS_LITETICKET_HOST=liteticket.$FRONTEND" --env="SYS_LITETICKET_PORT=8872" --env="SYS_LITETICKET_VERSION=$HOST_VERSION" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_PORT=8828" --env="SYS_ARDSLITESERVICE_VERSION=$HOST_VERSION" --env="SYS_DYNAMICCONFIGGENERATOR_HOST=dynamicconfigurationgenerator.$FRONTEND" --env="SYS_DYNAMICCONFIGGENERATOR_PORT=8816" --env="SYS_DYNAMICCONFIGGENERATOR_VERSION=$HOST_VERSION" --env="SYS_HTTPROGRAMINGAPI_HOST=httpprogrammingapi.$FRONTEND" --env="SYS_HTTPROGRAMINGAPI_PORT=8807" --env="SYS_HTTPROGRAMINGAPI_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=smppclient.*" --env="LB_FRONTEND=smppclient.$FRONTEND" --env="LB_PORT=$LB_PORT" --log-opt max-size=10m --log-opt max-file=10 --restart=always --name smppclient smppclient:$VERSION_TAG node /usr/local/src/smppclient/app.js;
;;

 "reportqueryfilters")
#53
cd /usr/src/;
if [ ! -d "DVP-ReportQueryFilters" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone -b $VERSION_TAG https://github.com/DuoSoftware/DVP-ReportQueryFilters.git;
fi
cd DVP-ReportQueryFilters;
docker build --build-arg VERSION_TAG=$VERSION_TAG -t "reportqueryfilters:"$VERSION_TAG .;
cd /usr/src/;
docker run -d -t --memory="256m" -v /etc/localtime:/etc/localtime:ro --env="VERSION_TAG=$VERSION_TAG" --env="COMPOSE_DATE=$DATE" --env="NODE_CONFIG_DIR=/usr/local/src/reportqueryfilters/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_REPORTQUERYFILTERS_PORT=8846" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_REDIS_MODE=$REDIS_MODE" --env="SYS_REDIS_SENTINEL_HOSTS=$REDIS_SENTINEL_HOSTS" --env="SYS_REDIS_SENTINEL_PORT=$REDIS_SENTINEL_PORT" --env="SYS_REDIS_SENTINEL_NAME=$REDIS_SENTINEL_NAME" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_REPLICASETNAME=$MONGO_REPLICA_SET_NAME" --env="VIRTUAL_HOST=reportqueryfilters.*" --env="LB_FRONTEND=reportqueryfilters.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8846/tcp -p 8846:8846 --log-opt max-size=10m --log-opt max-file=10 --restart=always --name reportqueryfilters reportqueryfilters:$VERSION_TAG node /usr/local/src/reportqueryfilters/app.js;
;;

esac
done
 

