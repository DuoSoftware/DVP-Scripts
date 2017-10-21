#!/usr/bin/python
#
# script is created for clearing IVR logs
#
import commands
import logging

LOG_FILENAME = '/var/log/syslog'
logging.basicConfig(filename=LOG_FILENAME,
                    level=logging.INFO,
                    )

IVR_PATH=['/var/www/html/IVR/duoIVR/','/var/www/html/IVR/dfccIVR/']
IVR_LOG_FILE_NAME='process.log'

i=0
while i<len(IVR_PATH):
	command = commands.getoutput('truncate -s 0 {0}{1}'.format(IVR_PATH[i],IVR_LOG_FILE_NAME))
	i+=1
	logging.info('IVRLoghandler:Truncate IVR Log Completed.')
