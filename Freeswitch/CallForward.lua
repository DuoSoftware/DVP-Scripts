
--table of return cause of phone like dictionary--
--tableName["RETURN_STRING_OF_SIP_PHONE"] = "CAUSE" -- 
obParam = {}
obParam["USER_BUSY"] = "USER_BUSY"
obParam["NO_USER_RESPONSE"] = "USER_BUSY"
--obParam["USER_NOT_REGISTERED"] = "USER_BUSY"--
obParam["NO_ANSWER"] = "NO_ANSWER"


session:setAutoHangup(false)

  

    local obCause = argv[1]
contex_var = "CF"
company_var = argv[2]
tenant_var = argv[3]
guuserid_var = argv[4]
contex2_var = argv[5]
fromguuserid_var = argv[6]
domain_var = argv[7]
fromuser_var = argv[8]
fromnumber_var = argv[9]

cFCause = obParam[obCause]

        --freeswitch.consoleLog("info", "aaaaaaaaaaaaa = " ..argv[].. "\n")

        freeswitch.consoleLog("info", "obSession:hangupCause() = " .. obCause.."\n" )
	freeswitch.consoleLog("info", "company = " ..company_var .. "\n")
	freeswitch.consoleLog("info", "tenant = " ..tenant_var .. "\n")
	freeswitch.consoleLog("info", "GuUserId = " ..guuserid_var .. "\n")
	freeswitch.consoleLog("info", "Context = " ..contex2_var .. "\n")
	freeswitch.consoleLog("info", "FromGuUserId = " ..fromguuserid_var .. "\n")
	freeswitch.consoleLog("info", "Domain  = " ..domain_var .. "\n")	
	freeswitch.consoleLog("info", "TableVal = "..cFCause.. "\n")        
	freeswitch.consoleLog("info", "FromUser = "..fromuser_var.. "\n")
	freeswitch.consoleLog("info", "FromNumber = "..fromnumber_var.. "\n")


str_var = contex_var.."/"..company_var.."/"..tenant_var.."/"..guuserid_var.."/"..cFCause.."/"..contex2_var.."/"..fromguuserid_var.."/"..domain_var.."/"..fromuser_var.."/"..fromnumber_var

	freeswitch.consoleLog("info", "Return_String = " ..str_var .. "\n")

    if ( cFCause == "USER_BUSY" ) then          
	session:transfer(str_var, "XML", contex2_var)
	--session:transfer("5000", "XML", "default")
    elseif ( cFCause == "NO_ANSWER" ) then
        session:transfer(str_var, "XML", contex2_var)
	-- session:hangup()
    elseif ( cFCause == "ORIGINATOR_CANCEL" ) then  
        session:transfer(str_var, "XML", contex2_var)
    else
	session:hangup()
    end


