#!/usr/bin/python
#	Script Developed for Dialog Impelemtation 
#	creatd by Dasun Hettiarachchi
#	13-09-2017
#

from lxml import etree
import os
import sys
import commands
import logging 

import psycopg2
import sys
import datetime
import config as cfg

LOG_FILENAME = 'fsmanager.log'
logging.basicConfig(filename=LOG_FILENAME,
                    level=logging.DEBUG,
                    )
ProfileName = sys.argv[1]
profileIP = sys.argv[2]
CompanyId = sys.argv[3]

print 'Company Name: '+ ProfileName + ' IP: ' + profileIP
logging.debug('Company Name: '+ProfileName + ' IP: ' + profileIP)

try:
	xml_file = "/usr/src/fsmanager/sample.xml"
	logging.debug('Reading Sample XML file')
	xml_file_output = '/etc/freeswitch/sip_profiles/' + ProfileName +'.xml'.format(os.path.splitext(xml_file)[0])
	print 'Creating XML Profile Completed...'
	logging.debug('Created Internal Profile Name: ' + ProfileName)
	logging.debug('Profile copied to /etc/freeswitch/sip_profiles')
	parser = etree.XMLParser(remove_comments=False)
	tree = etree.parse(xml_file, parser)
	root = tree.getroot()

	for param in root.iter("param"):
   		replaced_ip = param.get("value").replace("0.0.0.0", profileIP)
   		param.set("value", replaced_ip)
   		
   	for name in root.iter("profile"):
		replace_name = name.get("name").replace("sample", ProfileName)
		name.set("name", replace_name)
		logging.debug('Assigned IP address' + ProfileName + ' to company name ' + profileIP)
		logging.debug('Assigned company name to profile ' + sys.argv[2])
	print 'IP Added into Profile Completed...'
	
	tree.write(xml_file_output)
except:
	print "Operation Failed"
	logging.debug('Operation Failed..Please contact Implementation')
else:
	print 'XML Deploy Completed...'
	logging.debug('XML Profile deployed sucessfully')

try:
	con = None
	con = psycopg2.connect(database=cfg.postgres['db'], user = cfg.postgres['user'], password = cfg.postgres['passwd'], host = cfg.postgres['host'], port = cfg.postgres['port'])
	logging.debug('Postgres connection established..')
	cur = con.cursor()

	date = datetime.datetime.now()
	logging.debug('Inserting to CSDB_SipNetworkProfiles')
	sqlinsert = """INSERT INTO "CSDB_SipNetworkProfiles" ("MainIp","ProfileName","InternalIp","InternalRtpIp","ExternalIp","ExternalRtpIp","Port",
		"ObjClass","ObjType","ObjCategory","CompanyId","TenantId","createdAt","updatedAt","CallServerId") 
		VALUES('{0}','{1}','{2}','{3}','{4}','{5}',5060,'DVP','INTERNAL','INTERNAL','{6}',1,'{7}','{8}','1')""".format(profileIP,ProfileName,profileIP,profileIP,profileIP,profileIP,CompanyId,date,date)
	cur.execute(sqlinsert) 
	con.commit()
	print "Insert into CSDB_SipNetworkProfiles done"
except psycopg2.DatabaseError, e:
    
    if con:
        con.rollback()
    
    print 'Error %s' % e  
    logging.debug('Inserting to CSDB_SipNetworkProfiles Failed')
    sys.exit(1)
    
    
finally:
    
    if con:
        con.close()

	
try:
   file=open("ifaceID", "r")
   output=file.read()
   logging.debug('Reading ifaceID file...')
   c = int(output)+1

#print output, c

   file2write=open("ifaceID",'w')
   file2write.write('%d' % c)
   
#print c

   file2write=open("/etc/network/interfaces",'a')
   line1 = 'auto eth0:' + str(c)
   line2 = 'iface eth0:' + str(c) +' inet static'
   line3 = 'address' +' '+ profileIP
   line4 = 'netmask 255.255.255.0'
   file2write.write("%s \n %s \n %s \n %s \n" % (line1, line2, line3, line4))
   logging.debug('Insert virtual interface card to network')
except IOError:
   print "Error: Can't find file or read data"
   logging.debug('Operation Failed...Can\t find file or read')

else:
   print "Virtual Interface added sucessfully"
   logging.debug('Virtual interface added ' + 'eth0'+str(c)+ 'IP ' + profileIP)
   file2write.close()

try:
	command1 = commands.getoutput('ifup eth0:'+str(c))
	logging.debug('executing ifup on eth0'+profileIP)
	command = commands.getoutput('fs_cli -x "sofia profile ' + ProfileName + ' start"')
	logging.debug('starting sofia' + ProfileName + 'profile')
	print "Profile " +  ProfileName + " Load Completed in Freeswitch"

except:
   print "Loading Profile in FS Failed"
   logging.debug('Loading Profiles in fs failed' +ProfileName )
