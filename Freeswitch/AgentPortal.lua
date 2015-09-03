
company = argv[1];
tenant = argv[2];


session:answer();

session:set_tts_params("flite", "kal");

session:speak("Welcome to the agent portal, Please enter your agentid");
agentidx = session:getDigits(8, "#", 5000);

session:flushDigits();

session:speak("Welcome to the agent portal, Please enter your pin number");
pinx = session:getDigits(4, "#", 5000);


session:flushDigits();


agentQuery = string.format("http://192.168.0.15:2225/DVP/API/1.0.0.0/ARDS/%s/%s/resource/%s/%s",company, tenant, agentidx, pinx);

session:execute("curl", agentQuery)
curl_response_code_agent = session:getVariable("curl_response_code")
curl_response_agent      = session:getVariable("curl_response_data")





if curl_response_code_agent == "200" then


	agentstatusQuery = string.format("http://192.168.0.15:2225/DVP/API/1.0.0.0/ARDS/%s/%s/resource/%s/state",company, tenant,agentidx);

	session:execute("curl", agentstatusQuery)
	curl_response_code_agent_status = session:getVariable("curl_response_code")
	curl_response_agent_status      = session:getVariable("curl_response_data")
	status =curl_response_agent_status;


	satatusString = string.format("You are successfully loged in to the systam, your current state is %s, if you want to toggle state please press 1 press 2 to logoff",status);
	session:speak(satatusString);
	option = session:getDigits(1, "#", 5000);
	session:flushDigits()

	statusx = Available;
	if option == "1" then

		if status == 'NotAvailable' then

			statusx = Available;


		elseif status == 'Available' then

			statusx = NotAvailable;

		else
			statusx = Available;
				
		end


		agentStatus = string.format("http://192.168.0.15:2225/DVP/API/1.0.0.0/ARDS/%s/%s/resource/%s/state/%s put",company,tenant,curl_response_agent, statusx);
		session:execute("curl", agentStatus);
		curl_response_code_set = session:getVariable("curl_response_code");

		session:speak("Now Your are in %s state", statusx);
		session:hangup();

	elseif option == "2" then

		agentlogoff = string.format("http://192.168.0.15:2225/DVP/API/1.0.0.0/ARDS/%s/%s/resource/%s delete",company,tenant,curl_response_agent);
		session:execute("curl", agentlogoff);
		curl_response_code_logoff = session:getVariable("curl_response_code");

		session:speak("Lou are logged off successfully");
		session:hangup();
				

	else

		session:speak("Your are still in %s state", statusx);
		session:hangup();

	end	

elseif curl_response_code_agent == "403" then

	session:speak("UserID or Password wrong, please try again");
	session:hangup();

end