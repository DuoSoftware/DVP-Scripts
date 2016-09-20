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


IFS=', ' read -r -a array <<< "$DEPLOY";
#echo "${array[2]}";


#Install Docker

#which curl
#sudo apt-get install curl -y
#curl -sSL https://get.docker.com/ | sh
#curl -sSL https://get.docker.com/gpg | sudo apt-key add -

# Install Nginx-Proxy

#docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy

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
	git clone git://github.com/DuoSoftware/DVP-DynamicConfigurationGenerator.git;
fi
cd DVP-DynamicConfigurationGenerator;
docker build -t "dynamicconfigurationgenerator:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/dynamicconfigurationgenerator/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION"  --env="HOST_DYNAMICCONFIGGEN_PORT=8816" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=dynamicconfigurationgenerator.*" --env="LB_FRONTEND=dynamicconfigurationgenerator.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8816/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name dynamicconfigurationgenerator dynamicconfigurationgenerator node /usr/local/src/dynamicconfigurationgenerator/app.js;
;;
   "resourceservice")
#2
cd /usr/src/;
if [ ! -d "DVP-ResourceService" ]; then
	git clone git://github.com/DuoSoftware/DVP-ResourceService.git;
fi

cd DVP-ResourceService;
docker build -t "resourceservice:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/resourceservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_RESOURCESERVICE_PORT=8831" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=resourceservice.*" --env="LB_FRONTEND=resourceservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8831/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name resourceservice resourceservice node /usr/local/src/resourceservice/app.js;

;;
   "ardsmonitoring")
#3
cd /usr/src/;
if [ ! -d "DVP-ARDSMonitoring" ]; then
	git clone git://github.com/DuoSoftware/DVP-ARDSMonitoring.git;
fi

cd DVP-ARDSMonitoring;
docker build -t "ardsmonitoring:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/ardsmonitoring/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ARDSMONITOR_PORT=8830" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_ARDSLITEROUTINGENGINE_HOST=ardsliteroutingengine.$FRONTEND" --env="SYS_ARDSLITEROUTINGENGINE_PORT=8835" --env="SYS_ARDSLITEROUTINGENGINE_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="VIRTUAL_HOST=ardsmonitoring.*" --env="LB_FRONTEND=ardsmonitoring.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8830/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ardsmonitoring ardsmonitoring node /usr/local/src/ardsmonitoring/app.js;

;;
   "phonenumbertrunkservice")
#4
cd /usr/src/;
if [ ! -d "DVP-PhoneNumberTrunkService" ]; then
	git clone git://github.com/DuoSoftware/DVP-PhoneNumberTrunkService.git;
fi

cd DVP-PhoneNumberTrunkService;
docker build -t "phonenumbertrunkservice:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/phonenumbertrunkservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_PHONENUMBERTRUNKSERVICE_PORT=8818" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=phonenumbertrunkservice.*" --env="LB_FRONTEND=phonenumbertrunkservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8818/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name phonenumbertrunkservice phonenumbertrunkservice node /usr/local/src/phonenumbertrunkservice/app.js;

;;
   "limithandler")
#5
cd /usr/src/;
if [ ! -d "DVP-LimitHandler" ]; then
	git clone git://github.com/DuoSoftware/DVP-LimitHandler.git;
fi

cd DVP-LimitHandler;
docker build -t "limithandler:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/limithandler/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_LIMITHANDLER_PORT=8815" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=limithandler.*" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="LB_FRONTEND=limithandler.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8815/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name limithandler limithandler node /usr/local/src/limithandler/app.js;

;;
   "ardsliteroutingengine")
#6
cd /usr/src/;
if [ ! -d "DVP-ARDSLiteRoutingEngine" ]; then
	git clone git://github.com/DuoSoftware/DVP-ARDSLiteRoutingEngine.git;
fi

cd DVP-ARDSLiteRoutingEngine;
docker build -t "ardsliteroutingengine:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-ARDSLiteRoutingEngine/ArdsLiteRoutingEngine" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ARDSLITEROUTINGENGINE_PORT=8835" --env="HOST_IP=$HOST_IP"  --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=ardsliteroutingengine.*" --env="LB_FRONTEND=ardsliteroutingengine.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --expose=8835/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ardsliteroutingengine ardsliteroutingengine go run *.go;

;;
   "notificationservice")
#7
cd /usr/src/;
if [ ! -d "DVP-NotificationServicee" ]; then
	git clone git://github.com/DuoSoftware/DVP-NotificationService.git;
fi

cd DVP-NotificationService;
docker build -t "notificationservice:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/notificationservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_NOTIFICATIONSERVICE_PORT=8833" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=notificationservice.*" --env="LB_FRONTEND=notificationservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8833/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name notificationservice notificationservice node /usr/local/src/notificationservice/app.js;

;;
   "engagementservice")
#8
cd /usr/src/;
if [ ! -d "DVP-Engagement" ]; then
	git clone git://github.com/DuoSoftware/DVP-Engagement.git;
fi

cd DVP-Engagement;
docker build -t "engagementservice:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/engagementservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ENGAGEMENTSERVICE_PORT=8834" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD" --env="VIRTUAL_HOST=engagementservice.*" --env="LB_FRONTEND=engagementservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8834/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name engagementservice engagementservice node /usr/local/src/engagementservice/app.js;

;;
   "campaignmanager")
#9
cd /usr/src/;
if [ ! -d "DVP-CampaignManager" ]; then
	git clone git://github.com/DuoSoftware/DVP-CampaignManager.git;
fi

cd DVP-CampaignManager;
docker build -t "campaignmanager:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/campaignmanager/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CAMPAIGNMANAGER_PORT=8827" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=campaignmanager.*" --env="LB_FRONTEND=campaignmanager.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8827/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name campaignmanager campaignmanager node /usr/local/src/campaignmanager/app.js;

;;
   "pbxservice")
#10
cd /usr/src/;
if [ ! -d "DVP-PBXService" ]; then
	git clone git://github.com/DuoSoftware/DVP-PBXService.git;
fi

cd DVP-PBXService;
docker build -t "pbxservice:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/pbxservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_PBXSERVICE_PORT=8820" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_SIPUSERSERVICE_HOST=sipuserendpointservice.$FRONTEND" --env="SYS_SIPUSERSERVICE_NODE_CONFIG_DIR=/usr/local/src/sipuserendpointservice/config" --env="SYS_SIPUSERSERVICE_PORT=8814"  --env="SYS_SIPUSERSERVICE_VERSION=$HOST_VERSION" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_NODE_CONFIG_DIR=/usr/local/src/fileservice/config" --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=pbxservice.*" --env="LB_FRONTEND=pbxservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8820/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name pbxservice pbxservice node /usr/local/src/pbxservice/app.js;

;;
   "callbackservice")
#11
cd /usr/src/;
if [ ! -d "DVP-CallBackService" ]; then
	git clone git://github.com/DuoSoftware/DVP-CallBackService.git;
fi

cd DVP-CallBackService;
docker build -t "callbackservice:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-CallBackService/CallbackServer" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CALLBACKSERVICE_PORT=8840" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_CAMPAIGNMANAGER_HOST=campaignmanager.$FRONTEND" --env="SYS_CAMPAIGNMANAGER_NODE_CONFIG_DIR=/usr/local/src/campaignmanager/config" --env="SYS_CAMPAIGNMANAGER_PORT=8827" --env="VIRTUAL_HOST=callbackservice.*" --env="LB_FRONTEND=callbackservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8840/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name callbackservice callbackservice go run *.go;

;;
   "voxboneapi")
#12
cd /usr/src/;
if [ ! -d "DVP-VoxboneAPI" ]; then
	git clone git://github.com/DuoSoftware/DVP-VoxboneAPI.git;
fi

cd DVP-VoxboneAPI;
docker build -t "voxboneapi:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/voxboneapi/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="VOXBONE_URL=https://sandbox.voxbone.com/ws-voxbone/services/rest" --env="HOST_VOXBONEAPI_PORT=8832" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_PHONENUMBERTRUNKSERVICE_HOST=phonenumbertrunkservice.$FRONTEND" --env="SYS_PHONENUMBERTRUNKSERVICE_NODE_CONFIG_DIR=/usr/local/src/phonenumbertrunkservice/config" --env="SYS_PHONENUMBERTRUNKSERVICE_PORT=8818" --env="SYS_LIMITHANDLER_HOST=limithandler.$FRONTEND" --env="SYS_LIMITHANDLER_NODE_CONFIG_DIR=/usr/local/src/limithandler/config" --env="SYS_LIMITHANDLER_PORT=8815" --env="VIRTUAL_HOST=voxboneapi.*" --env="LB_FRONTEND=voxboneapi.$FRONTEND" --env="LB_PORT=80" --expose=8832/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name voxboneapi voxboneapi node /usr/local/src/voxboneapi/app.js;

;;
   "ruleservice")
#13
cd /usr/src/;
if [ ! -d "DVP-RuleService" ]; then
	git clone git://github.com/DuoSoftware/DVP-RuleService.git;
fi

cd DVP-RuleService;
docker build -t "ruleservice:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/ruleservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_RULESERVICE_PORT=8817" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=ruleservice.*" --env="LB_FRONTEND=ruleservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8817/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ruleservice ruleservice node /usr/local/src/ruleservice/app.js;

;;
   "conference")
#14
cd /usr/src/;
if [ ! -d "DVP-Conference" ]; then
	git clone git://github.com/DuoSoftware/DVP-Conference.git;
fi

cd DVP-Conference;
docker build -t "conference:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/conference/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="HOST_NAME=conference" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_CONFERENCE_PORT=8821" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=conference.*" --env="LB_FRONTEND=conference.$FRONTEND" --env="LB_PORT=LB_PORT" --expose 8821 --log-opt max-size=10m --log-opt max-file=10 --restart=always --name conference conference node /usr/local/src/conference/app.js;

;;
   "httpprogrammingapidebug")
#15
cd /usr/src/;
if [ ! -d "DVP-HTTPProgrammingAPIDEBUG" ]; then
	git clone git://github.com/DuoSoftware/DVP-HTTPProgrammingAPIDEBUG.git;
fi

cd DVP-HTTPProgrammingAPIDEBUG;
docker build -t "httpprogrammingapidebug:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/httpprogrammingapidebug/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_HTTPPROGRAMMINGAPIDEBUG_PORT=8825" ---env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_HTTPPROGRAMMINGAPI_HOST=httpprogrammingapi.$FRONTEND" --env="VIRTUAL_HOST=httpprogrammingapidebug.*" --env="LB_FRONTEND=httpprogrammingapidebug.$FRONTEND" --env="LB_PORT=LB_PORT" --expose=8825/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name httpprogrammingapidebug httpprogrammingapidebug node /usr/local/src/httpprogrammingapidebug/app.js 

;;
   "interactions")
#16
cd /usr/src/;
if [ ! -d "DVP-Interactions" ]; then
	git clone git://github.com/DuoSoftware/DVP-Interactions.git;
fi

cd DVP-Interactions;
docker build -t "interactions:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/interactions/config" --env="HOST_TOKEN=$HOST_TOKEN"  --env="HOST_INTERACTIONS_PORT=8873" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="VIRTUAL_HOST=interactions.*" --env="LB_FRONTEND=interactions.$FRONTEND" --env="LB_PORT=LB_PORT" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_SIPUSERENDPOINTSERVICE_HOST=rsipuserendpointservice.$FRONTEND" --env="SYS_SIPUSERENDPOINTSERVICE_PORT=8814" --env="SYS_SIPUSERENDPOINTSERVICE_VERSION=$HOST_VERSION" --env="SYS_CLUSTERCONFIG_HOST=clusterconfig.$FRONTEND" --env="SYS_CLUSTERCONFIG_PORT=8805" --env="SYS_CLUSTERCONFIG_VERSION=$HOST_VERSION" --expose=8873/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name interactions interactions node /usr/local/src/interactions/app.js

;;
   "templates")
#17
cd /usr/src/;
if [ ! -d "DVP-Templates" ]; then
	git clone git://github.com/DuoSoftware/DVP-Templates.git
fi

cd DVP-Templates;
docker build -t "templates:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/templates/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_TEMPLATE_PORT=8875" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=templates.*" --env="LB_FRONTEND=templates.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8875/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name templates templates node /usr/local/src/templates/app.js;

;;
   "ardsliteservice")
#18
cd /usr/src/;
if [ ! -d "DVP-ARDSLiteService" ]; then
	git clone git://github.com/DuoSoftware/DVP-ARDSLiteService.git;
fi

cd DVP-ARDSLiteService;
docker build -t "ardsliteservice:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/ardsliteservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_ARDSLITESERVICE_PORT=8828" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_ARDSLITEROUTINGENGINE_HOST=ardsliteroutingengine.$FRONTEND" --env="SYS_ARDSLITEROUTINGENGINE_GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-ARDSLiteRoutingEngine/ArdsLiteRoutingEngine" --env="SYS_ARDSLITEROUTINGENGINE_PORT=8835" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=ardsliteservice.*" --env="LB_FRONTEND=ardsliteservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --expose=8828/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name ardsliteservice ardsliteservice node /usr/local/src/ardsliteservice/app.js;

;;
   "userservice")
#19
cd /usr/src/;
if [ ! -d "DVP-UserService" ]; then
	git clone git://github.com/DuoSoftware/DVP-UserService.git;
fi

cd DVP-UserService;
docker build -t "userservice:latest" .;
cd /usr/src/;
#docker run -d -t --env="NODE_CONFIG_DIR=/usr/local/src/userservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_USERSERVICE_PORT=8842" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="VIRTUAL_HOST=userservice.*" --env="LB_FRONTEND=userservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8842/tcp --restart=always --name userservice userservice node /usr/local/src/userservice/app.js;
docker run -d -t --memory="512m" --net=host --env='NODE_CONFIG_DIR=/usr/local/src/userservice/config' --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_USERSERVICE_PORT=8842" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="VIRTUAL_HOST=userservice.*" --env="LB_FRONTEND=userservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND" --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_SIPUSERENDPOINTSERVICE_HOST=rsipuserendpointservice.$FRONTEND" --env="SYS_SIPUSERENDPOINTSERVICE_PORT=8814" --env="SYS_SIPUSERENDPOINTSERVICE_VERSION=$HOST_VERSION" --env="SYS_CLUSTERCONFIG_HOST=clusterconfig.$FRONTEND" --env="SYS_CLUSTERCONFIG_PORT=8805" --env="SYS_CLUSTERCONFIG_VERSION=$HOST_VERSION" --expose=8842/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name userservice userservice node /usr/local/src/userservice/app.js

;;
   "internalcdrprocessor")
#20
cd /usr/src/;
if [ ! -d "DVP-InternalCDRProcessor" ]; then
	git clone git://github.com/DuoSoftware/DVP-InternalCDRProcessor.git;
fi

cd DVP-InternalCDRProcessor;
docker build -t "internalcdrprocessor:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/cdrprocessor_internal/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_INTERNALCDRPROCESSOR_PORT=8809" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=internalcdrprocessor.*" --env="LB_FRONTEND=internalcdrprocessor.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8809/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name internalcdrprocessor internalcdrprocessor node /usr/local/src/cdrprocessor_internal/app.js;

;;
   "monitorrestapi")
#21
cd /usr/src/;
if [ ! -d "DVP-MonitorRestAPI" ]; then
	git clone git://github.com/DuoSoftware/DVP-MonitorRestAPI.git;
fi

cd DVP-MonitorRestAPI;
docker build -t "monitorrestapi:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/monitorrestapi/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_MONITORRESTAPI_PORT=8823" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=monitorrestapi.*" --env="LB_FRONTEND=monitorrestapi.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8823/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name monitorrestapi monitorrestapi node /usr/local/src/monitorrestapi/app.js;

;;
   "httpprogrammingapi")
#22
cd /usr/src/;
if [ ! -d "DVP-HTTPProgrammingAPI" ]; then
	git clone git://github.com/DuoSoftware/DVP-HTTPProgrammingAPI.git;
fi

cd DVP-HTTPProgrammingAPI;
docker build -t "httpprogrammingapi:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/httpprogrammingapi/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_FREESWITCH_HOST=$FREESWITCH_HOST"  --env="SYS_EVENTSOCKET_PORT=$EVENTSOCKET_PORT" --env="FS_PASSWORD=$FREESWITCH_EVENTSOCKET_PASSWORD" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="HOST_HTTPPROGRAMMINGAPI_PORT=8807" --env="SYS_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_FILESERVICE_NODE_CONFIG_DIR=/usr/local/src/fileservice/config" --env="SYS_FILESERVICE_PORT=8812" --env="SYS_FILESERVICE_VERSION=$HOST_VERSION" --env="SYS_DOWNLOAD_FILESERVICE_HOST=fileservice.$FRONTEND" --env="SYS_DOWNLOAD_FILESERVICE_PORT=8812" --env="SYS_DOWNLOAD_FILESERVICE_VERSION=$HOST_VERSION" --env="SYS_RULESERVICE_HOST=$RULESERVICE_HOST" --env="SYS_RULESERVICE_PORT=8817" --env="SYS_RULESERVICE_VERSION=ruleservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_NODE_CONFIG_DIR=/usr/local/src/ardsliteservice/config" --env="SYS_ARDSLITESERVICE_PORT=8828" --env="SYS_QUEUEMUSIC_HOST=queuemusic.$FRONTEND" --env="SYS_QUEUEMUSIC_PORT=8843" --env="SYS_QUEUEMUSIC_VERSION=$HOST_VERSION" --env="SYS_INTERACTION_HOST=interactions.$FRONTEND" --env="SYS_INTERACTION_PORT=8873" --env="SYS_INTERACTION_VERSION=$HOST_VERSION" --env="SYS_TICKET_HOST=liteticket.$FRONTEND" --env="SYS_TICKET_PORT=8872" --env="SYS_TICKET_VERSION=1.0.0.0" --env="VIRTUAL_HOST=httpprogrammingapi.*" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="LB_FRONTEND=httpprogrammingapi.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8807/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name httpprogrammingapi httpprogrammingapi node /usr/local/src/httpprogrammingapi/app.js;

;;
   "sipuserendpointservice")
#23
cd /usr/src/;
if [ ! -d "DVP-SIPUserEndpointService" ]; then
	git clone git://github.com/DuoSoftware/DVP-SIPUserEndpointService.git;
fi

cd DVP-SIPUserEndpointService;
docker build -t "sipuserendpointservice:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/sipuserendpointservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="HOST_SIPUSERENDPOINTSERVICE_PORT=8814" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_LBDATABASE_MYSQL_USER=$LBDATABASE_MYSQL_USER" --env="SYS_LBDATABASE_MYSQL_PASSWORD=$LBDATABASE_MYSQL_PASSWORD" --env="SYS_LBDATABASE_HOST=$LBDATABASE_HOST" --env="SYS_LBDATABASE_TYPE=$LBDATABASE_TYPE" --env="SYS_LBMYSQL_PORT=$LBMYSQL_PORT" --env="SYS_LBDATABASE_MYSQL_DB=$LBDATABASE_MYSQL_DB" --env="VIRTUAL_HOST=sipuserendpointservice.*" --env="LB_FRONTEND=sipuserendpointservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8814/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name sipuserendpointservice sipuserendpointservice node /usr/local/src/sipuserendpointservice/app.js;

;;
   "clusterconfig")
#24
cd /usr/src/;
if [ ! -d "DVP-ClusterConfiguration" ]; then
	git clone git://github.com/DuoSoftware/DVP-ClusterConfiguration.git;
fi

cd DVP-ClusterConfiguration;
docker build -t "clusterconfig:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/clusterconfiguration/config" --env="HOST_CLUSTERCONFIGURATION_PORT=8805" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=clusterconfig.*" --env="LB_FRONTEND=clusterconfig.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8805/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name clusterconfig clusterconfig node /usr/local/src/clusterconfiguration/app.js;

;;
   "eventmonitor")
#25
cd /usr/src/;
if [ ! -d "DVP-EventMonitor" ]; then
	git clone git://github.com/DuoSoftware/DVP-EventMonitor.git;
fi

cd DVP-EventMonitor;
docker build -t "eventmonitor:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/eventmonitor/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_EVENTMONITOR_PORT=8806" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=DuoS123" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_NODE_CONFIG_DIR=/usr/local/src/ardsliteservice/config" --env="SYS_ARDSLITESERVICE_PORT=8828" --env="SYS_ARDSLITESERVICE_VERSION=$HOST_VERSION" --env="SYS_DIALER_HOST=dialerapi.$FRONTEND" --env="SYS_DIALER_GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-DialerAPI/DuoDialer" --env="SYS_DIALER_PORT=8836" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="SYS_FREESWITCH_HOST=$FREESWITCH_HOST" --env="SYS_FREESWITCH_EVENTSOCKET_PASSWORD=$FREESWITCH_EVENTSOCKET_PASSWORD" --env="SYS_XMLRPC_PORT=$XMLRPC_PORT" --env="SYS_EVENTSOCKET_PORT=$EVENTSOCKET_PORT" --env="VIRTUAL_HOST=eventmonitor.*" --env="LB_FRONTEND=eventmonitor.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8806/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name eventmonitor eventmonitor node /usr/local/src/eventmonitor/app.js;

;;
   "queuemusic")
#26
cd /usr/src/;
if [ ! -d "DVP-QueueMusic" ]; then
	git clone git://github.com/DuoSoftware/DVP-QueueMusic.git;
fi

cd DVP-QueueMusic;
docker build -t "queuemusic:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/queuemusic/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="HOST_NAME=queuemusic" --env="HOST_QUEUEMUSIC_PORT=8843" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=queuemusic.*" --env="LB_FRONTEND=queuemusic.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8843/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name queuemusic queuemusic node /usr/local/src/queuemusic/app.js;

;;
   "appregistry")
#27
cd /usr/src/;
if [ ! -d "DVP-APPRegistry" ]; then
	git clone git://github.com/DuoSoftware/DVP-APPRegistry.git;
fi

cd DVP-APPRegistry;
docker build -t "appregistry:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/appregistry/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="HOST_APPREGISTRY_PORT=8811" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="VIRTUAL_HOST=appregistry.*" --env="LB_FRONTEND=appregistry.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8811/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name appregistry appregistry node /usr/local/src/appregistry/app.js;

;;
   "autoattendant")
#28
cd /usr/src/;
if [ ! -d "DVP-AutoAttendant" ]; then
	git clone git://github.com/DuoSoftware/DVP-AutoAttendant.git;
fi

cd DVP-AutoAttendant;
docker build -t "autoattendant:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/autoattendant/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT"  --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_AUTOATTENDANT_PORT=8824" --env="VIRTUAL_HOST=autoattendant.*" --env="LB_FRONTEND=autoattendant.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8824/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name autoattendant autoattendant node /usr/local/src/autoattendant/app.js;

;;
   "dialerapi")
#29
cd /usr/src/;
if [ ! -d "DVP-DialerAPI" ]; then
	git clone git://github.com/DuoSoftware/DVP-DialerAPI.git;
fi

cd DVP-DialerAPI;
docker build -t "dialerapi:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-DialerAPI/DuoDialer" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_IP=$HOST_IP" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="HOST_DIALER_PORT=8836" --env="SYS_RULESERVICE_HOST=ruleservice.$FRONTEND" --env="SYS_RULESERVICE_NODE_CONFIG_DIR=/usr/local/src/ruleservice/config" --env="SYS_RULESERVICE_PORT=8817" --env="SYS_CAMPAIGNMANAGER_HOST=campaignmanager.$FRONTEND" --env="SYS_CAMPAIGNMANAGER_NODE_CONFIG_DIR=/usr/local/src/campaignmanager/config" --env="SYS_CAMPAIGNMANAGER_PORT=8827" --env="SYS_LIMITHANDLER_HOST=limithandler.$FRONTEND" --env="SYS_LIMITHANDLER_NODE_CONFIG_DIR=/usr/local/src/limithandler/config" --env="SYS_LIMITHANDLER_PORT=8815" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND" --env="SYS_NOTIFICATIONSERVICE_NODE_CONFIG_DIR=/usr/local/src/notificationservice/config" --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND" --env="SYS_ARDSLITESERVICE_NODE_CONFIG_DIR=/usr/local/src/ardsliteservice/config" --env="SYS_ARDSLITESERVICE_PORT=8828" --env="SYS_CALLBACKSERVICE_HOST=callbackservice.$FRONTEND" --env="SYS_CALLBACKSERVICE_PORT=8840" --env="SYS_FREESWITCH_HOST=$FREESWITCH_HOST" --env="SYS_FREESWITCH_EVENTSOCKET_PASSWORD=$FREESWITCH_EVENTSOCKET_PASSWORD" --env="SYS_XMLRPC_PORT=$XMLRPC_PORT" --env="SYS_EVENTSOCKET_PORT=$EVENTSOCKET_PORT" --env="SYS_CLUSTERCONFIGURATION_HOST=clusterconfig.$FRONTEND" --env="SYS_CLUSTERCONFIGURATION_PORT=8805" --env="VIRTUAL_HOST=dialerapi.*" --env="LB_FRONTEND=dialerapi.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8836/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name dialerapi dialerapi go run *.go;

;;
   "dashboard")
#30
cd /usr/src/;
if [ ! -d "DVP-DashBoard" ]; then
	git clone git://github.com/DuoSoftware/DVP-DashBoard.git
fi

cd DVP-DashBoard;
docker build -t "dashboard:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="GO_CONFIG_DIR=/go/src/github.com/DuoSoftware/DVP-DashBoard" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_DASHBOARD_PORT=8841" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT"  --env="SYS_STATSD_HOST=$STATSD_HOST" --env="SYS_STATSD_PORT=$STATSD_PORT" --env="VIRTUAL_HOST=dashboard.*" --env="LB_FRONTEND=dashboard.$FRONTEND" --env="LB_PORT=80" --expose=8841/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name dashboard dashboard go run *.go
#docker run -d -t
;;
   "cdrprocessor")
#31
cd /usr/src/;
if [ ! -d "DVP-CDRProcessor" ]; then
	git clone git://github.com/DuoSoftware/DVP-CDRProcessor.git;
fi

cd DVP-CDRProcessor;
docker build -t "cdrprocessor:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/cdrprocessor/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CDRPROCESSOR_PORT=8809" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=cdrprocessor.*" --env="LB_FRONTEND=cdrprocessor.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8809/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name cdrprocessor cdrprocessor node /usr/local/src/cdrprocessor/app.js;

;;
   "eventservice")
#32
cd /usr/src/;
if [ ! -d "DVP-EventService" ]; then
	git clone git://github.com/DuoSoftware/DVP-EventService.git
fi

cd DVP-EventService;
docker build -t "eventservice:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env='NODE_CONFIG_DIR=/usr/local/src/eventservice/config' --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_VERSION=$HOST_VERSION" --env="HOST_EVENTSERVICE_PORT=8822" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_RABBITMQ_HOST=$RABBITMQ_HOST" --env="SYS_RABBITMQ_PORT=$RABBITMQ_PORT" --env="SYS_RABBITMQ_USER=$RABBITMQ_USER" --env="SYS_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD" --env="VIRTUAL_HOST=eventservice.*" --env="LB_FRONTEND=eventservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8822/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name eventservice eventservice node /usr/local/src/eventservice/app.js
#docker run -d -t

;;
   "liteticket")
#33
cd /usr/src/;
if [ ! -d "DVP-LiteTicket" ]; then
	git clone git://github.com/DuoSoftware/DVP-LiteTicket.git
fi

cd DVP-LiteTicket;
docker build -t "liteticket:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/liteticket/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_LITETICKET_PORT=8872" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="VIRTUAL_HOST=liteticket.*" --env="LB_FRONTEND=liteticket.$FRONTEND"  --env="LB_PORT=$LB_PORT" --env="SYS_RESOURCESERVICE_HOST=resourceservice.$FRONTEND"  --env="SYS_RESOURCESERVICE_PORT=8831" --env="SYS_RESOURCESERVICE_VERSION=$HOST_VERSION" --env="SYS_SIPUSERENDPOINTSERVICE_HOST=rsipuserendpointservice.$FRONTEND"  --env="SYS_SIPUSERENDPOINTSERVICE_PORT=8814" --env="SYS_SIPUSERENDPOINTSERVICE_VERSION=$HOST_VERSION" --env="SYS_CLUSTERCONFIG_HOST=clusterconfig.$FRONTEND"  --env="SYS_CLUSTERCONFIG_PORT=8805" --env="SYS_CLUSTERCONFIG_VERSION=$HOST_VERSION" --env="SYS_ARDSLITESERVICE_HOST=ardsliteservice.$FRONTEND"  --env="SYS_ARDSLITESERVICE_PORT=8828" --env="SYS_ARDSLITESERVICE_VERSION=$HOST_VERSION" --env="SYS_NOTIFICATIONSERVICE_HOST=notificationservice.$FRONTEND"  --env="SYS_NOTIFICATIONSERVICE_PORT=8833" --env="SYS_NOTIFICATIONSERVICE_VERSION=$HOST_VERSION" --env="SYS_SCHEDULEWORKER_HOST=scheduleworker.$FRONTEND"  --env="SYS_SCHEDULEWORKER_PORT=8852" --env="SYS_SCHEDULEWORKER_VERSION=$HOST_VERSION" --expose=8872/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name liteticket liteticket node /usr/local/src/liteticket/app.js
#docker run -d -t

;;
   "httpprogrammingmonitorapi")
#34
cd /usr/src/;
if [ ! -d "DVP-HTTPProgrammingMonitorAPI" ]; then
	git clone git://github.com/DuoSoftware/DVP-HTTPProgrammingMonitorAPI.git;
fi

cd DVP-HTTPProgrammingMonitorAPI;
docker build -t "httpprogrammingmonitorapi:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env='NODE_CONFIG_DIR=/usr/local/src/httpprogrammingmonitorapi/config' --env="HOST_TOKEN=$HOST_TOKEN"  --env="HOST_HTTPPROGRAMMINGMONITORAPI_PORT=8813"--env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=httpprogrammingmonitorapi.*" --env="LB_FRONTEND=httpprogrammingmonitorapi.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8813/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name httpprogrammingmonitorapi httpprogrammingmonitorapi node /usr/local/src/httpprogrammingmonitorapi/app.js
#docker run -d -t
;;

   "scheduleworker")
 #35
cd /usr/src/;
if [ ! -d "DVP-ScheduleWorker" ]; then
	git clone git://github.com/DuoSoftware/DVP-ScheduleWorker.git
fi
cd DVP-ScheduleWorker;
docker build -t "scheduleworker:latest" .;
cd /usr/src/;
docker run -d -t--memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/scheduleworker/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_SCHEDULEWORKER_PORT=8852" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=scheduleworker.*" --env="LB_FRONTEND=scheduleworker.$FRONTEND"  --env="LB_PORT=$LB_PORT" --expose=8852/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name scheduleworker scheduleworker node /usr/local/src/scheduleworker/app.js
#docker run -d -t
;;

 "fileservice")
#36
cd /usr/src/;
if [ ! -d "DVP-FileService" ]; then
  # Control will enter here if $DIRECTORY exists.
  git clone git://github.com/DuoSoftware/DVP-FileService.git;
fi
cd DVP-FileService;
docker build -t "fileservice:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/fileservice/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_FILESERVICE_PORT=8812" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="SYS_MONGO_HOST=$MONGO_HOST" --env="SYS_MONGO_USER=$MONGO_USER" --env="SYS_MONGO_PASSWORD=$MONGO_PASSWORD"  --env="SYS_MONGO_DB=$MONGO_DB" --env="SYS_MONGO_PORT=$MONGO_PORT" --env="SYS_COUCH_HOST=$COUCH_HOST" --env="SYS_COUCH_PORT=$COUCH_PORT" --env="VIRTUAL_HOST=fileservice.*" --env="LB_FRONTEND=fileservice.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8812/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name fileservice fileservice node /usr/local/src/fileservice/app.js;
;;

   "cdrgenerator")
#37
cd /usr/src/;
if [ ! -d "DVP-CDRGenerator" ]; then
	git clone git://github.com/DuoSoftware/DVP-CDRGenerator.git;
fi

cd DVP-CDRGenerator;
docker build -t "cdrgenerator:latest" .;
cd /usr/src/;
docker run -d -t --memory="512m" --net=host --env="NODE_CONFIG_DIR=/usr/local/src/cdrgenerator/config" --env="HOST_TOKEN=$HOST_TOKEN" --env="HOST_CDRGENERATOR_PORT=8859" --env="HOST_VERSION=$HOST_VERSION" --env="SYS_DATABASE_HOST=$DATABASE_HOST" --env="SYS_DATABASE_TYPE=$DATABASE_TYPE" --env="SYS_DATABASE_POSTGRES_USER=$DATABASE_POSTGRES_USER" --env="SYS_DATABASE_POSTGRES_PASSWORD=$DATABASE_POSTGRES_PASSWORD" --env="SYS_SQL_PORT=$SQL_PORT" --env="SYS_REDIS_HOST=$REDIS_HOST" --env="SYS_REDIS_PASSWORD=$REDIS_PASSWORD" --env="SYS_REDIS_PORT=$REDIS_PORT" --env="VIRTUAL_HOST=cdrgenerator.*" --env="LB_FRONTEND=cdrgenerator.$FRONTEND" --env="LB_PORT=$LB_PORT" --expose=8859/tcp --log-opt max-size=10m --log-opt max-file=10 --restart=always --name cdrgenerator cdrgenerator node /usr/local/src/cdrgenerator/app.js;

;;

esac
done

