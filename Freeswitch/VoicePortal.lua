

local dbh = freeswitch.Dbh("odbc://PostgreSQL30:duo:DuoS123")
company = argv[1];
tenant = argv[2];
pin = argv[3];
userid = argv[4];
templateid = argv[5];
status = argv[6];
action = argv[7];
voicemail = argv[8];
onbusy = argv[9];
onanswer = argv[10];


--DND, CALL_DIVERT, AVAILABLE

session:answer();

session:set_tts_params("flite", "kal");
session:speak("Welcome to the voice portal, Please enter your pin number");
digits = session:getDigits(4, "#", 5000);

	
statusx = status
	
if status == 'DND' then

statusx= "DND";
	
elseif status == 'AVAILABLE' then

statusx = "ACTIVE"
		
elseif status == 'CALL_DIVERT' then


statusx = "AWAY"
			
else
			
end



if digits == pin then

	session:flushDigits();
	satatusString = string.format("You are successfully loged in to the systam, your current state is %s, if you want to change status please press 1 or press 2 for status based actions",statusx);
	session:speak(satatusString);
	digits = session:getDigits(1, "#", 5000);
	
	if digits == "1" then
	
		session:speak("Pressed 1");
		
		if status == 'DND' then
		
			session:flushDigits();
			session:speak("You are in dnd mode, please press 1");
			digits = session:getDigits(1, "#", 5000);
			
			if digits == "1" then 
									
			satatusUpdateQuery = string.format("UPDATE \"CSDB_PBXUsers\" SET \"UserStatus\" = 'AVAILABLE' WHERE \"UserUuid\" = '%s'", userid);
			freeswitch.consoleLog("notice", satatusUpdateQuery);
			dbh:query(satatusUpdateQuery);
			
			session:speak("You are now in active mode");
			
			else
			
			session:speak("Your are still in dnd mode");
			
			end
			
		
		elseif status == 'AVAILABLE' then
		
			session:flushDigits();
			session:speak("You are in active mode, please press 1 for go to away mode, press 2 for go to dnd mode");
			digits = session:getDigits(1, "#", 5000);
			
			if digits == "1" then 
			
			session:speak("You are now in away mode");
			
			satatusUpdateQuery = string.format("UPDATE \"CSDB_PBXUsers\" SET \"UserStatus\" = 'CALL_DIVERT' WHERE \"UserUuid\" = '%s'", userid);
			freeswitch.consoleLog("notice", satatusUpdateQuery);
			dbh:query(satatusUpdateQuery);
			
			elseif digits == "2" then 
			
			session:speak("Your are now in dnd mode");
			
			satatusUpdateQuery = string.format("UPDATE \"CSDB_PBXUsers\" SET \"UserStatus\" = 'DND' WHERE \"UserUuid\" = '%s'", userid);
			freeswitch.consoleLog("notice", satatusUpdateQuery);
			dbh:query(satatusUpdateQuery);
			
			else
			
			session:speak("Your are still in active mode");
			
			end
		
		
		
		elseif status == 'CALL_DIVERT' then
		
			session:flushDigits();
			session:speak("You are in away mode, If you want to go to active, please press 1");
			digits = session:getDigits(1, "#", 5000);
			
			if digits == "1" then 
			
			session:speak("You are now in active mode");
			
			satatusUpdateQuery = string.format("UPDATE \"CSDB_PBXUsers\" SET \"UserStatus\" = 'AVAILABLE' WHERE \"UserUuid\" = '%s'", userid);
			freeswitch.consoleLog("notice", satatusUpdateQuery);
			dbh:query(satatusUpdateQuery);
			
			else
			
			session:speak("Your are still in away mode");
			
			end
		
		else
		
		end
		
		
	elseif digits == "2" then
	
			session:speak("Pressed 2");
		
		if status == "DND" then
			
			session:speak("There are no action related to dnd status");
		
		elseif status == "CALL_DIVERT" then
		
			session:flushDigits();
			session:speak("Please press 1 for divert call, press 2 for active voicemail");
			digits = session:getDigits(1, "#", 5000);
			
			if digits == "1" then
			

				session:flushDigits();
				session:speak("Please enter divert number");
				digits = session:getDigits(15, "#", 10000);
				numdata = digits;
				num = string.gsub (digits, "", " ");
				
				
				session:flushDigits();
				numberPressed = string.format("Number you entered is %s, please press 1 for confirm", num);
				session:speak(numberPressed);
				digits = session:getDigits(1, "#", 5000);
				
				if digits == "1" then
				
					
					
					satatusUpdateQuery = string.format("UPDATE \"CSDB_PBXUserTemplates\" SET \"CallDivertNumber\" = '%s' WHERE \"id\" = %s",numdata, templateid);
					freeswitch.consoleLog("notice", satatusUpdateQuery);
					dbh:query(satatusUpdateQuery);
					
					session:speak("Your Divert number is set successfuly");
				
				else
				
					session:speak("Your number is not set");
				
				end
			
			elseif digits == "2" then
			
			
				satatusUpdateQuery = string.format("UPDATE \"CSDB_PBXUsers\" SET \"VoicemailEnabled\" = true WHERE \"UserUuid\" = '%s'", userid);
				freeswitch.consoleLog("notice", satatusUpdateQuery);
				dbh:query(satatusUpdateQuery);
			
				session:speak("Your voicemail activated");
			
			else
			
			end
		
		
		
		elseif status == "AVAILABLE" then
		
			session:flushDigits();
			session:speak("Please press 1 for set onbusy forwarding number, press 2 for set noanswer forwarding number");
			digits = session:getDigits(1, "#", 5000);
			
			if digits == "1" then
			
				session:flushDigits();
				session:speak("Please enter onbusy forwarding number");
				digits = session:getDigits(15, "#", 10000);
				numdata = digits;
				num = string.gsub (digits, "", " ");
				
				session:flushDigits();
				numberPressed = string.format("Number you entered is %s, please press 1 for confirm", num);
				session:speak(numberPressed);
				digits = session:getDigits(1, "#", 5000);
				
				if digits == "1" then
				
					if onbusy == "none" then
					
					
					
					
						satatusUpdateQuery = string.format("INSERT INTO \"CSDB_Forwardings\"(\"DestinationNumber\", \"RingTimeout\", \"CompanyId\", \"TenantId\", \"ObjClass\", \"ObjType\", \"ObjCategory\", \"DisconnectReason\", \"IsActive\", \"createdAt\", \"updatedAt\", \"PBXUserUuid\") VALUES ('%s', 60, %s, %s, 'DVP', 'PBX', 'FWD', 'BUSY', true, '1999-09-09 00:00:00+06','1999-09-09 00:00:00+06', %s)",numdata,company, tenant, userid);
						freeswitch.consoleLog("notice", satatusUpdateQuery);
						dbh:query(satatusUpdateQuery);
					
					
					
					else
				
						satatusUpdateQuery = string.format("UPDATE \"CSDB_Forwardings\" SET \"DestinationNumber\" = '%s' WHERE \"id\" = %s",numdata, onbusy);
						freeswitch.consoleLog("notice", satatusUpdateQuery);
						dbh:query(satatusUpdateQuery);
					end
				
				
					session:speak("Your onbusy forwarding number set successfuly");
				
				else
				
					session:speak("Your number is not set");
				
				end
				
				
				
			elseif digits == "2" then
			
				session:flushDigits();
				session:speak("Please enter noanswer forwarding number");
				digits = session:getDigits(15, "#", 10000);
				numdata = digits;
				num = string.gsub (digits, "", " ");
				
				session:flushDigits();
				numberPressed = string.format("Number you entered is %s, please press 1 for confirm", num);
				session:speak(numberPressed);
				digits = session:getDigits(1, "#", 5000);
				
				if digits == "1" then
				
					if onanswer == "none" then
					
						satatusUpdateQuery = string.format("INSERT INTO \"CSDB_Forwardings\"(\"DestinationNumber\", \"RingTimeout\", \"CompanyId\", \"TenantId\", \"ObjClass\", \"ObjType\", \"ObjCategory\", \"DisconnectReason\", \"IsActive\", \"createdAt\", \"updatedAt\", \"PBXUserUuid\") VALUES ('%s', 60, %s, %s, 'DVP', 'PBX', 'FWD', 'NO_ANSWER', true, '1999-09-09 00:00:00+06','1999-09-09 00:00:00+06', %s)",numdata,company, tenant, userid);
						freeswitch.consoleLog("notice", satatusUpdateQuery);
						dbh:query(satatusUpdateQuery);
					
					
					else
				
						satatusUpdateQuery = string.format("UPDATE \"CSDB_Forwardings\" SET \"DestinationNumber\" = '%s' WHERE \"id\" = %s",numdata, onanswer);
						freeswitch.consoleLog("notice", satatusUpdateQuery);
						dbh:query(satatusUpdateQuery);
					end
				
					session:speak("Your noanswer forwarding number set successfuly");
				
				else
				
					session:speak("Your number is not set");
				
				end
			
			else
			
			end
		
				
		
		else
		
		end
		
		
			
	else
	
		session:hangup();
	
	end
	
else

	session:speak("Password wrong, please try again");

end
