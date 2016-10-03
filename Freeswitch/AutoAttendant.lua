
-- db_connect.lua
-- Connects to a database using freeswitch.dbh connection pooling, checks PIN, reads balance
-- A hangup function makes the code a bit cleaner
 

local dbh = freeswitch.Dbh("odbc://PostgreSQL30:duo:DuoS123") -- sqlite database in subdirectory "db"
local row = {}


company = argv[1];
tenant = argv[2];
extention = argv[3];
contextTo = argv[5];
contextFrom = argv[4];
rowx = {};


--dbh:test_reactive("SELECT * FROM my_table",
--                  "DROP TABLE my_table",
--                  "CREATE TABLE my_table (id INTEGER(8), name VARCHAR(255))")
 
--dbh:query("INSERT INTO my_table VALUES(1, 'foo')")
--dbh:query("INSERT INTO my_table VALUES(2, 'bar')")

query = string.format("SELECT * FROM \"CSDB_AutoAttendants\" WHERE (\"Extention\"='%s' AND \"Company\"=%s AND \"Tenant\"=%s) LIMIT 1 ", extention, company, tenant)

 
dbh:query(query, function(row)

freeswitch.consoleLog("notice", string.format("%s : %s\n", row.Code, row.Name))
rowx = row
session:answer()
session:streamFile(row.DayGreeting)

length = 1;


freeswitch.consoleLog("notice", string.format("Extention details %s %s\n", row.EnableExtention, row.ExtentionLength))


if row.EnableExtention == "1" then

length = row.ExtentionLength

end

		

fileurl = string.format("  http://fileservice.app.veery.cloud/DVP/API/1.0.0.0/InternalFileService/File/DownloadLatest/%s/%s/%s", tenant, company, row.MenuSound)
freeswitch.consoleLog("notice", fileurl)
		
destnum = session:playAndGetDigits(1,length, row.Tries, row.TimeOut, "#", fileurl, "/invalid.wav", "\\S+", "my_digit")



terminator = session:getVariable("read_terminator_used")
issuccess = session:getVariable("read_result")
freeswitch.consoleLog("notice", string.format("Digit number %s terminator result %s\n", destnum, issuccess))

if issuccess == "success" then

	if (string.len(destnum) > 1) and (row.EnableExtention == "1")then
	
	new_session = freeswitch.Session(string.format("user/%s",destnum), session);
	freeswitch.bridge(session, new_session);
	 
	elseif string.len(destnum) == 1 then
	
	
		actionQuery = string.format("SELECT * FROM \"CSDB_Actions\" WHERE (\"CSDBAutoAttendantId\" = %s AND \"OnEvent\" = '%s') LIMIT 1", row.id, destnum);
	freeswitch.consoleLog("notice",actionQuery);
		dbh:query(actionQuery, function(rowy)
		
		freeswitch.consoleLog("notice", string.format("----------------------------------------------->%s", rowy.Action));
			
			if rowy.Action == "route" then
			
				new_sessionx = freeswitch.Session(string.format("user/%s",rowy.Data), session);
				freeswitch.bridge(session, new_sessionx);
			
			elseif rowy.Action == "play" then
			
			session:streamFile(rowy.Data)
			
			elseif rowy.Action == "end" then
			
			session:hangup("USER_BUSY");
			
			
			elseif rowy.Action == "transfer" then
			
			session:transfer(rowy.Data, "XML", contextTo);
			
			else
			
			
			session:hangup("USER_BUSY");
			
			end
			
			
		
		
		end)



	else 

	freeswitch.consoleLog("notice", string.format( "Didnt go through command %d %d %d \n",string.len(destnum),row.ExtentionLength,row.EnableExtention))
	
	end

elseif issuccess == "timeout" then

		actionQuery = string.format("SELECT * FROM \"CSDB_Actions\" WHERE (\"CSDBAutoAttendantId\" = %s AND \"OnEvent\" = '%s') LIMIT 1", row.id, destnum);
		freeswitch.consoleLog("notice",actionQuery);
		

		dbh:query(actionQuery, function(rowy)
		
		freeswitch.consoleLog("notice", string.format("--------------------------------------------------------------->%s", rowy.Action));
			
			if rowy.Action == "route" then
			
				new_sessionx = freeswitch.Session(string.format("user/%s",rowy.Data), session);
				freeswitch.bridge(session, new_sessionx);
			
			elseif rowy.Action == "play" then
			
			session:streamFile(rowy.Data)
			
			elseif rowy.Action == "end" then
				session:hangup("USER_BUSY");
			
			elseif rowy.Action == "transfer" then
			
			session:transfer(rowy.Data, "XML", contextTo);
			
			else
			
			session:hangup("USER_BUSY");
			
			end
		
		
		end)


else 

	actionQuery = string.format("SELECT * FROM \"CSDB_Actions\" WHERE (\"CSDBAutoAttendantId\" = %s AND \"OnEvent\" = 'default') LIMIT 1", row.id, destnum);
		freeswitch.consoleLog("notice",actionQuery);
		

		dbh:query(actionQuery, function(rowy)
		
		freeswitch.consoleLog("notice", string.format("--------------------------------------------------------------->%s", rowy.Action));
			
			if rowy.Action == "route" then
			
				new_sessionx = freeswitch.Session(string.format("user/%s",rowy.Data), session);
				freeswitch.bridge(session, new_sessionx);
			
			elseif rowy.Action == "play" then
			
			session:streamFile(rowy.Data)
			
			elseif rowy.Action == "end" then
				session:hangup("USER_BUSY");
			
			elseif rowy.Action == "transfer" then
			
			session:transfer(rowy.Data, "XML", contextTo);
			
			else
			
			session:hangup("USER_BUSY");
			
			end
		
		
		end)

end

end)
 
--dbh:query("UPDATE my_table SET name = 'changed'")


 
function hangup_call ()
    session:streamFile("ivr/ivr-thank_you.wav")
    session:sleep(250)
    session:streamFile("voicemail/vm-goodbye.wav")
    session:hangup()
end
 
if dbh:connected() == false then
   freeswitch.consoleLog("notice", "gen_dir_user_xml.lua cannot connect to database" .. dsn .. "\n")
   hangup_call()  
end
 
