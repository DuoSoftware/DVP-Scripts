#!/bin/bash



FRONTEND_IP_PORT="192.168.51.247:5000"

FRONTEND="pickme.lk" 

APP_SVR_ONE="app1"

APP_SVR_TWO="app2"

APP_SVR_THREE="app3"







#--hipache insert data to redis



#--curl --request POST 'http://192.168.2.188:5000/frontends?host=dynamicconfigurationgenerator.192.168.2.188.$FRONTEND&backends=http://dynamicconfigurationgenerator.192.168.2.180.$FRONTEND,http://dynamicconfigurationgenerator.192.168.2.182.$FRONTEND'



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=dynamicconfigurationgenerator.$FRONTEND&backends=http://dynamicconfigurationgenerator.$APP_SVR_ONE.$FRONTEND,http://dynamicconfigurationgenerator.$APP_SVR_TWO.$FRONTEND,http://dynamicconfigurationgenerator.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=httpprogrammingapi.$FRONTEND&backends=http://httpprogrammingapi.$APP_SVR_ONE.$FRONTEND,http://httpprogrammingapi.$APP_SVR_TWO.$FRONTEND,http://httpprogrammingapi.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=ardsliteroutingengine.$FRONTEND&backends=http://ardsliteroutingengine.$APP_SVR_ONE.$FRONTEND,http://ardsliteroutingengine.$APP_SVR_TWO.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=ardsliteservice.$FRONTEND&backends=http://ardsliteservice.$APP_SVR_ONE.$FRONTEND,http://ardsliteservice.$APP_SVR_THTEE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=eventmonitor.$FRONTEND&backends=http://eventmonitor.$APP_SVR_TWO.$FRONTEND,http://eventmonitor.$APP_SVR_THTEE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=internalcdrprocessor.$FRONTEND&backends=http://internalcdrprocessor.$APP_SVR_ONE.$FRONTEND,http://internalcdrprocessor.$APP_SVR_TWO.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=internalfileservice.$FRONTEND&backends=http://internalfileservice.$APP_SVR_ONE.$FRONTEND,http://internalfileservice.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=limithandler.$FRONTEND&backends=http://limithandler.$APP_SVR_TWO.$FRONTEND,http://limithandler.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=pbxservice.$FRONTEND&backends=http://pbxservice.$APP_SVR_ONE.$FRONTEND,http://pbxservice.$APP_SVR_TWO.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=queuemusic.$FRONTEND&backends=http://queuemusic.$APP_SVR_ONE.$FRONTEND,http://queuemusic.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=userservice.$FRONTEND&backends=http://userservice.$APP_SVR_TWO.$FRONTEND,http://userservice.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=cdrprocessor.$FRONTEND&backends=http://cdrprocessor.$APP_SVR_ONE.$FRONTEND,http://cdrprocessor.$APP_SVR_TWO.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=engagementservice.$FRONTEND&backends=http://engagementservice.$APP_SVR_TWO.$FRONTEND,http://engagementservice.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=fileservice.$FRONTEND&backends=http://fileservice.$APP_SVR_ONE.$FRONTEND,http://fileservice.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=monitorrestapi.$FRONTEND&backends=http://monitorrestapi.$APP_SVR_ONE.$FRONTEND,http://monitorrestapi.$APP_SVR_TWO.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=notificationservice.$FRONTEND&backends=http://notificationservice.$APP_SVR_TWO.$FRONTEND,http://notificationservice.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=sipuserendpointservice.$FRONTEND&backends=http://sipuserendpointservice.$APP_SVR_ONE.$FRONTEND,http://sipuserendpointservice.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=appregistry.$FRONTEND&backends=http://appregistry.$APP_SVR_ONE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=ardsmonitoring.$FRONTEND&backends=http://ardsmonitoring.$APP_SVR_TWO.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=autoattendant.$FRONTEND&backends=http://autoattendant.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=callbackservice.$FRONTEND&backends=http://callbackservice.$APP_SVR_ONE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=campaignmanager.$FRONTEND&backends=http://campaignmanager.$APP_SVR_TWO.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=clusterconfig.$FRONTEND&backends=http://clusterconfig.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=conference.$FRONTEND&backends=http://conference.$APP_SVR_ONE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=dialerapi.$FRONTEND&backends=http://dialerapi.$APP_SVR_TWO.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=phonenumbertrunkservice.$FRONTEND&backends=http://phonenumbertrunkservice.$APP_SVR_THREE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=resourceservice.$FRONTEND&backends=http://resourceservice.$APP_SVR_ONE.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=ruleservice.$FRONTEND&backends=http://ruleservice.$APP_SVR_TWO.$FRONTEND";



curl --request POST "http://$FRONTEND_IP_PORT/frontends?host=voxboneapi.$FRONTEND&backends=http://voxboneapi.$APP_SVR_THREE.$FRONTEND";





#docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock centurylink/watchtower




