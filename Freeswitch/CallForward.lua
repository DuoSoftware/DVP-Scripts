
--table of return cause of phone like dictionary--
--tableName["RETURN_STRING_OF_SIP_PHONE"] = "CAUSE" --
obParam = {}
obParam["USER_BUSY"] = "BUSY"
obParam["NO_USER_RESPONSE"] = "BUSY"
--obParam["USER_NOT_REGISTERED"] = "USER_BUSY"--
obParam["NO_ANSWER"] = "NO_ANSWER"


session:setAutoHangup(false)

--disconreson, CompanyId, TenantId, context, Domain, Origination, OriginationCallerIdNumber, fwdKey, DodNumber

local obCause = argv[1]
contex_var = "CF"
company_var = argv[2]
tenant_var = argv[3]
contex2_var = argv[4]
domain_var = argv[5]
origination_var = argv[6]
originationCallerIdNumber_var = argv[7]
fwdKey_var = argv[8]
dodNumber_var = argv[9]

--fromguuserid_var = argv[6]
--fromuser_var = argv[8]
--fromnumber_var = argv[9]
--guuserid_var = argv[4]


cFCause = obParam[obCause]

        --freeswitch.consoleLog("info", "aaaaaaaaaaaaa = " ..argv[].. "\n")

    freeswitch.consoleLog("info", "obSession:hangupCause() = " .. obCause.."\n" )
        freeswitch.consoleLog("info", "company = " ..company_var .. "\n")
        freeswitch.consoleLog("info", "tenant = " ..tenant_var .. "\n")
        freeswitch.consoleLog("info", "Origination = " ..origination_var .. "\n")
        freeswitch.consoleLog("info", "Context = " ..contex2_var .. "\n")
        freeswitch.consoleLog("info", "OriginationCallerIdNumber = " ..originationCallerIdNumber_var .. "\n")
        freeswitch.consoleLog("info", "Domain  = " ..domain_var .. "\n")
        freeswitch.consoleLog("info", "TableVal = "..cFCause.. "\n")
        freeswitch.consoleLog("info", "FwdKey = "..fwdKey_var.. "\n")
        freeswitch.consoleLog("info", "DodNumber = "..dodNumber_var.. "\n")

------



--                                      fwdKey_var        var fwdId = dnisSplitArr[1];
--                  company_var      var companyId = dnisSplitArr[2];
--                  tenant_var     var tenantId = dnisSplitArr[3];
--                  obCause      var disconReason = dnisSplitArr[4];
--                  dodNumber_var      var dodNumber = dnisSplitArr[5];
--                  contex2_var      var context = dnisSplitArr[6];
--                  origination_var      var origination = dnisSplitArr[7];
--                  originationCallerIdNumber_var      var origCallerIdNum = dnisSplitArr[8];


------
-- str_var = contex_var.."/"..company_var.."/"..tenant_var.."/"..guuserid_var.."/"..cFCause.."/"..contex2_var.."/"..fromguuserid_var.."/"..domain_var.."/"..fromuser_var.."/"..fromnumber_var
str_var = contex_var.."/"..fwdKey_var.."/"..company_var.."/"..tenant_var.."/"..cFCause.."/"..dodNumber_var.."/"..contex2_var.."/"..origination_var.."/"..originationCallerIdNumber_var

        freeswitch.consoleLog("info", "Return_String = " ..str_var .. "\n")

    if ( cFCause == "BUSY" ) then
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




