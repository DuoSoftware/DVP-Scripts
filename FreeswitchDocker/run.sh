#!/bin/bash

sed -i 's^<!-- <load module="mod_curl"/> -->^<load module="mod_curl"/>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^<!-- <load module="mod_spy"/> -->^<load module="mod_spy"/>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^<!-- <load module="mod_skinny"/> -->^<load module="mod_skinny"/>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^<!-- <load module="mod_cdr_sqlite"/> -->^<load module="mod_cdr_sqlite"/>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^<!-- <load module="mod_shout"/> -->^<load module="mod_shout"/>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^<!-- <load module="mod_syslog"/> -->^<load module="mod_syslog"/>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^<!-- <load module="mod_xml_rpc"/> -->^<load module="mod_xml_rpc"/>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^<!-- <load module="mod_xml_curl"/> -->^<load module="mod_xml_curl"/>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^<!-- <load module="mod_xml_cdr"/> -->^<load module="mod_xml_cdr"/>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^<!-- <load module="mod_xml_scgi"/> -->^<load module="mod_xml_scgi"/>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^</modules>^<load module="mod_ards"/> </modules>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^<!--<load module="mod_h26x"/>-->^<load module="mod_h26x"/>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^<!-- <load module="mod_flite"/> -->^<load module="mod_flite"/>^g' /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;
sed -i 's^<X-PRE-PROCESS cmd="set" data="global_codec_prefs=OPUS,G722,PCMU,PCMA,VP8"/>^<X-PRE-PROCESS cmd="set" data="global_codec_prefs=OPUS,G722,PCMU,PCMA,VP8,H.264,H.263,H264,H263-1998"/>^g' /usr/local/freeswitch/conf/vars.xml
sed -i 's^<X-PRE-PROCESS cmd="set" data="outbound_codec_prefs=OPUS,G722,PCMU,PCMA,VP8"/>^<X-PRE-PROCESS cmd="set" data="outbound_codec_prefs=OPUS,G722,PCMU,PCMA,VP8,H.264,H.263,H264,H263-1998"/>^g' /usr/local/freeswitch/conf/vars.xml
#echo '<load module="mod_ards"/>' >> /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml;

sed -i 's^<permission name="get-vars" value="false">^<permission name="get-vars" value="true">^g' /usr/local/freeswitch/conf/autoload_configs/httapi.conf.xml;
sed -i 's^<application name="hangup"/>^<application name="hangup"/> <application name="play_and_get_digits"/> <application name="execute"/>^g' /usr/local/freeswitch/conf/autoload_configs/httapi.conf.xml;
sed -i 's^<permission name="dial-set-context" value="false"/>^<permission name="dial-set-context" value="true"/>^g' /usr/local/freeswitch/conf/autoload_configs/httapi.conf.xml;
sed -i 's^<permission name="dial-set-dialplan" value="false"/>^<permission name="dial-set-dialplan" value="true"/>^g' /usr/local/freeswitch/conf/autoload_configs/httapi.conf.xml;
sed -i 's^<permission name="dial-set-cid-name" value="false"/>^<permission name="dial-set-cid-name" value="true"/>^g' /usr/local/freeswitch/conf/autoload_configs/httapi.conf.xml;
sed -i 's^<permission name="dial-set-cid-number" value="false"/>^<permission name="dial-set-cid-number" value="true"/>^g' /usr/local/freeswitch/conf/autoload_configs/httapi.conf.xml;
sed -i 's^<permission name="dial-full-originate" value="false"/>^<permission name="dial-full-originate" value="true"/>^g' /usr/local/freeswitch/conf/autoload_configs/httapi.conf.xml;
sed -i 's^<permission name="conference-set-profile" value="false"/>^<permission name="conference-set-profile" value="true"/>^g' /usr/local/freeswitch/conf/autoload_configs/httapi.conf.xml;

sed -i 's^</network-lists>^<list name="any" default="allow"> <node type="allow" cidr="192.168.42.42/32"/> </list> </network-lists>^g' /usr/local/freeswitch/conf/autoload_configs/acl.conf.xml

sed -i 's^</settings>^<param name="apply-inbound-acl" value="any"/> </settings>^g' /usr/local/freeswitch/conf/autoload_configs/event_socket.conf.xml;


#sed -i 's^param name="listen-ip" value="::"^param name="listen-ip" value="0.0.0.0"^g' /usr/local/freeswitch/conf/autoload_configs/event_socket.conf.xml;
if [[ ! -z $SYS_FS_EVENTSOCKET_PORT ]]
then
sed -i 's^<param name="listen-port" value="8021"/>^<param name="listen-port" value="'$SYS_FS_EVENTSOCKET_PORT'"/>^g' /usr/local/freeswitch/conf/autoload_configs/event_socket.conf.xml;
fi

if [[ ! -z $SYS_FS_EVENTSOCKET_PASSWORD ]]
then
sed -i 's^param name="password" value="ClueCon"^param name="password" value="'$SYS_FS_EVENTSOCKET_PASSWORD'"^g' /usr/local/freeswitch/conf/autoload_configs/event_socket.conf.xml;
fi

sed -i 's^<param name="auth-realm" value="freeswitch"/>^<!-- <param name="auth-realm" value="freeswitch"/> -->^g' /usr/local/freeswitch/conf/autoload_configs/xml_rpc.conf.xml;

if [[ ! -z $SYS_DYNAMICCONFIGGEN_HOST && $SYS_DYNAMICCONFIGGEN_VERSION ]]
then
sed -i 's^</bindings>^<binding name="directory"><param name="gateway-url" value="http://'$SYS_DYNAMICCONFIGGEN_HOST'/DVP/API/'$SYS_DYNAMICCONFIGGEN_VERSION'/DynamicConfigGenerator/DirectoryProfile" binding="directory"/></binding> <binding name="callapp"><param name="gateway-url" value="http://'$SYS_DYNAMICCONFIGGEN_HOST'/DVP/API/'$SYS_DYNAMICCONFIGGEN_VERSION'/DynamicConfigGenerator/CallApp" binding="dialplan"/></binding></bindings>^g' /usr/local/freeswitch/conf/autoload_configs/xml_curl.conf.xml;
fi

#if [[ ! -z $SYS_FS_EXTERNAL_IP ]]
#then
#sed -i 's^<domain name="$${domain}">^<domain name="'$FS_EXTERNALIP'">^g' /usr/local/freeswitch/conf/directory/default.xml;
#fi

if [[ ! -z $SYS_FS_EXTERNAL_IP ]]
then
sed -i 's^<param name="ext-rtp-ip" value="auto-nat"/>^<param name="ext-rtp-ip" value="'$SYS_FS_EXTERNAL_IP'"/>^g' /usr/local/freeswitch/conf/sip_profiles/internal.xml;
sed -i 's^<param name="ext-sip-ip" value="auto-nat"/>^<param name="ext-sip-ip" value="'$SYS_FS_EXTERNAL_IP'"/>^g' /usr/local/freeswitch/conf/sip_profiles/internal.xml;
fi


if [[ ! -z $SYS_ARDSLITESERVICE_HOST && ! -z $SYS_ARDSLITESERVICE_VERSION ]]
then
sed -i 's^<param name="url" value="http://www.google.com/DVP/API/1.0.0.0/ARDS/request"/>^<param name="url" value="http://'$SYS_ARDSLITESERVICE_HOST'/DVP/API/'$SYS_ARDSLITESERVICE_VERSION'/ARDS/request"/>^g' /usr/local/freeswitch/conf/autoload_configs/ards.conf.xml;
sed -i 's^<param name="register-url" value="http://www.google.com/DVP/API/1.0.0.0/ARDS/requestserver"/>^<param name="register-url" value="http://'$SYS_ARDSLITESERVICE_HOST'/DVP/API/'$SYS_ARDSLITESERVICE_VERSION'/ARDS/requestserver"/>^g' /usr/local/freeswitch/conf/autoload_configs/ards.conf.xml;
sed -i 's^<param name="xml_rpc" value="http://192.168.0.70:8080/api/ards_route"/>^<param name="xml_rpc" value="http://'$SYS_ARDSLITESERVICE_HOST'/api/ards_route"/>^g' /usr/local/freeswitch/conf/autoload_configs/ards.conf.xml;
fi

#sed -i 's^<param name="security_token" value="1#1"/>^
if [[ ! -z $SYS_QUEUEMUSIC_HOST && ! -z $SYS_QUEUEMUSIC_VERSION ]]
then
sed -i 's^<param name="profile-url" value="http://127.0.0.1:9093/DVP/API/1.0.0/QueueMusic/plain/Profile"/>^<param name="profile-url" value="http://'$SYS_QUEUEMUSIC_HOST'/DVP/API/'$SYS_QUEUEMUSIC_VERSION'/QueueMusic/plain/Profile"/>^g' /usr/local/freeswitch/conf/autoload_configs/ards.conf.xml;
fi

if [[ ! -z $SYS_FILESERVICE_HOST && ! -z $SYS_FILESERVICE_VERSION ]]
then
sed -i 's^<param name="upload-url" value="http://192.168.0.62:8081/DVP/API/6.0/FileService/File/Upload"/>^<param name="upload-url" value="http://'$SYS_FILESERVICE_HOST'/DVP/API/'$SYS_FILESERVICE_VERSION'/FileService/File/Upload"/>^g' /usr/local/freeswitch/conf/autoload_configs/ards.conf.xml;
fi

if [[ ! -z $SYS_NOTIFICATIONSERVICE_HOST && ! -z $SYS_NOTIFICATIONSERVICE_VERSION ]]
then
sed -i 's^<param name="notification_url" value="http://192.168.0.88:8086/DVP/API/6.0/NotificationService/Notification/initiate"/>^<param name="notification_url" value="http://'$SYS_NOTIFICATIONSERVICE_HOST'/DVP/API/'$SYS_NOTIFICATIONSERVICE_VERSION'/NotificationService/Notification/initiate"/>^g' /usr/local/freeswitch/conf/autoload_configs/ards.conf.xml;
fi

if [[ ! -z $SYS_FS_RTPSTART_PORT && ! -z $SYS_FS_RTPEND_PORT ]]
then
sed -i 's^<!-- <param name="rtp-start-port" value="16384"/> -->^<param name="rtp-start-port" value="'$SYS_FS_RTPSTART_PORT'"/>^g' /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml;
sed -i 's^<!-- <param name="rtp-end-port" value="32768"/> -->^<param name="rtp-end-port" value="'$SYS_FS_RTPEND_PORT'"/>^g' /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml;

EXPOSE  "'$SYS_FS_RTPSTART_PORT'-'$SYS_FS_RTPEND_PORT'/udp";
fi

if [[ ! -z $SYS_FS_ID ]]
then
sed -i 's^</settings>^<param name="switchname" value="'$SYS_FS_ID'"/></settings>^g' /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml;
fi

mv run.sh start_script.sh;
mv startfs.sh run.sh;
sh ./run.sh;

#/usr/local/freeswitch/bin/freeswitch -c
