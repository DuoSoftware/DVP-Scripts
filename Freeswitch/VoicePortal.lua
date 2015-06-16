local dbh = freeswitch.Dbh("odbc://PostgreSQL30:duo:DuoS123")

pin = argv[1];
userid = argv[2];
templateid = argv[3];
status = argv[4];
action = argv[5];
voicemail = argv[6];
onbusy = argv[7];
onanswer = argv[8];




session:set_tts_params("flite", "kal");
session:speak("Welcome to the voice portal, Please enter your pin number");
digits = session:getDigits(4, "#", 5000);



if digits == pin then

	session:flushDigits();
	satatusString = string.format("You are successfully loged in to the syatem, your current state is %s, if you want to change status please press 1 or press 2 for status based actions",status);
	session:speak(satatusString);
	digits = session:getDigits(1, "#", 5000);
	
	if digits == "1" then
	
		session:speak("Pressed 1");
		
		if status == 'dnd' then
		
			session:flushDigits();
			session:speak("You are in dnd mode, please press 1");
			digits = session:getDigits(1, "#", 5000);
			
			if digits == "1" then 
			
			session:speak("You are now in active mode");
			
			else
			
			session:speak("Your are still in dnd mode");
			
			end
			
		
		elseif status == 'active' then
		
			session:flushDigits();
			session:speak("You are in active mode, please press 1 for go to away mode, press 2 for go to dnd mode");
			digits = session:getDigits(1, "#", 5000);
			
			if digits == "1" then 
			
			session:speak("You are now in away mode");
			
			elseif digits == "2" then 
			
			session:speak("Your are now in dnd mode");
			
			else
			
			session:speak("Your are still in active mode");
			
			end
		
		
		
		elseif status == 'away' then
		
			session:flushDigits();
			session:speak("You are in away mode, If you want to go to active, please press 1");
			digits = session:getDigits(1, "#", 5000);
			
			if digits == "1" then 
			
			session:speak("You are now in active mode");
			
			else
			
			session:speak("Your are still in away mode");
			
			end
		
		else
		
		end
		
		
	elseif digits == "2" then
	
			session:speak("Pressed 2");
		
		if status == "dnd" then
			
			session:speak("There are no action related to dnd status");
		
		elseif status == "away" then
		
			session:flushDigits();
			session:speak("Please press 1 for divert call, press 2 for active voicemail");
			digits = session:getDigits(1, "#", 5000);
			
			if digits == "1" then
			

				session:flushDigits();
				session:speak("Please enter divert number");
				digits = session:getDigits(15, "#", 10000);
				
				
				session:flushDigits();
				numberPressed = string.format("Number you entered is %s, please press 1 for confirm", digits);
				session:speak(numberPressed);
				digits = session:getDigits(1, "#", 5000);
				
				if digits == "1" then
				
					session:speak("Your Divert number is set successfuly");
				
				else
				
					session:speak("Your number is not set");
				
				end
			
			elseif digits == "2" then
			
				session:speak("Your voicemail activated");
			
			else
			
			end
		
		
		
		elseif status == "active" then
		
			session:flushDigits();
			session:speak("Please press 1 for set onbusy forwarding number, press 2 for set noanswer forwarding number");
			digits = session:getDigits(1, "#", 5000);
			
			if digits == "1" then
			
				session:flushDigits();
				session:speak("Please enter onbusy forwarding number");
				digits = session:getDigits(15, "#", 10000);
				
				session:flushDigits();
				numberPressed = string.format("Number you entered is %s, please press 1 for confirm", digits);
				session:speak(numberPressed);
				digits = session:getDigits(1, "#", 5000);
				
				if digits == "1" then
				
					session:speak("Your onbusy forwarding number set successfuly");
				
				else
				
					session:speak("Your number is not set");
				
				end
				
				
				
			elseif digits == "2" then
			
				session:flushDigits();
				session:speak("Please enter noanswer forwarding number");
				digits = session:getDigits(15, "#", 10000);
				
				session:flushDigits();
				numberPressed = string.format("Number you entered is %s, please press 1 for confirm", digits);
				session:speak(numberPressed);
				digits = session:getDigits(1, "#", 5000);
				
				if digits == "1" then
				
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
