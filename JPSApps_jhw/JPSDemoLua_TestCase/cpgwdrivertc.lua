 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - CPGWDriver Test Case               ");
    print("--------------------------------------------------");
    print("CPGWDriverLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'     - To create the CPGW Intsance");
    print("- 'it'     - To initialize the CPGW");
    print("- 'st'     - To get the CPGW status");
    print("- 'ds'     - To dispose the printer");
    print("- 'cd'     - To send a card detect command");
    print("- 'sl'     - To send a set language command");
    print("- 'str'    - To send a start transaction command");
    print("- 'ctr'    - To send a confirm transaction command");
    print("- 'vtr'    - To send a void transaction command");
    print("- 'etr'    - To send an end transaction command");
    print("- 'rtr'    - To send a refund transaction command");
    print("- 'cpa'    - To send a change payment amount command");

    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function cpgwDriverTC()

    local msg;
	local usr_ref, ref, amount, refMode, papStat;
	
    repeat
        msg = _scheduler.pend();
        print("cpgwDrvTC-> msg=", msg);
    until(msg == "cpgwdrv");
    printMenu();

    local cpgwDrv = CPGWDriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = cpgwDrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
            print("create result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
            ret = cpgwDrv:init();
            print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = cpgwDrv:status();
            print("");
            print("--------------------------------------------------");
            print("Status: ");
            if(statusTable ~= nil) then
				print("EntityCode ", "'" .. statusTable["EntityCode"] .. "'");
                print("LastError ", "'" .. statusTable["LastError"] .. "'");
                print("Version  ", "'" .. statusTable["Version"] .. "'");
                alarmListTable = statusTable["alarmList"]
                if(alarmListTable ~= nil) then
                    print("alarmList:");
                    for key,value in pairs(alarmListTable) do --actualcode
                        print("--> ",key, alarmListTable[key]);
                    end
                end
				sensorListTable = statusTable["sensorList"]
                if(sensorListTable ~= nil) then
                    print("sensorList :");
                    for key,value in pairs(sensorListTable) do --actualcode
                        print("--> ",key, "",sensorListTable[key]);
                    end
                end
				print("");
            end
        -------------------------------------------------------
        elseif (in_line == "ds") then
            print("*** dispose ***");
            ret = cpgwDrv:dispose();
            print("dispose result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "cd") then
            print("*** card detect ***");
            print("Input the user reference parameter:");
            print(">");
            usr_ref = pop_lua_input();
            print("Input the amount:");
            print(">");
            amount = tonumber(pop_lua_input());

            if (amount ~= nil) then
                ret = cpgwDrv:cardDetect(usr_ref, amount);
                print("cardDetect result: " .. ret);
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "sl") then
            print("*** set language ***");
			print("Input the language parameter:");
            print(">");
            ret = cpgwDrv:setLanguage(pop_lua_input());
            print("setLanguage: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "str") then
            print("*** start transaction ***");
            print("Input the user reference parameter:");
            print(">");
            usr_ref = pop_lua_input();
            print("Input the amount:");
            print(">");
            amount = tonumber(pop_lua_input());
			print("Input the paper status aparameter (0 = Available, 1 = Low, 2 = Empty, 3 = Unavailable):");
            print(">");
            papStat = tonumber(pop_lua_input());

            if ((amount ~= nil) and (papStat ~= nil)) then
                ret = cpgwDrv:startTrnsct(usr_ref,amount,papStat);
                print("startTrnsct result: " .. ret);
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "ctr") then
            print("*** confirm transaction ***");
            print("Input the user reference parameter:");
            print(">");
			ret = cpgwDrv:confirmTrnsct(pop_lua_input());
			print("confirmTrnsct result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "vtr") then
            print("*** void transaction ***");
            print("Input the user reference parameter:");
            print(">");
			ret = cpgwDrv:voidTrnsct(pop_lua_input());
			print("voidTrnsct result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "etr") then
            print("*** end transaction ***");
            print("Input the user reference parameter:");
            print(">");
			ret = cpgwDrv:endTrnsct(pop_lua_input());
			print("endTrnsct result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "rtr") then
            print("*** refund transaction ***");
            print("Input the user reference parameter:");
            print(">");
            usr_ref = pop_lua_input();
            print("Input the reference parameter:");
            print(">");
            ref = pop_lua_input();
            print("Input the amount:");
            print(">");
            amount = tonumber(pop_lua_input());
			print("Input the refund mode parameter (0 = POS, 1 = WebDriver):");
            print(">");
            refMode = tonumber(pop_lua_input());

            if ((amount ~= nil) and (refMode ~= nil)) then
                ret = cpgwDrv:refundTrnsct(usr_ref,ref,amount,refMode);
                print("refundTrnsct result: " .. ret);
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "cpa") then
            print("*** change payment amount ***");
            print("Input the user reference parameter:");
            print(">");
            usr_ref = pop_lua_input();
            print("Input the amount:");
            print(">");
            amount = tonumber(pop_lua_input());

            if ((amount ~= nil)) then
                ret = cpgwDrv:chngPymtAmnt(usr_ref,amount);
                print("chngPymtAmnt result: " .. ret);
            else
                print("invalid option");
            end;
      -------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("cpgwDrvTC-> msg=", msg);
            until(msg == "cpgwdrv");
            printMenu();
		-------------------------------------------------------
        else
           if (string.len(in_line) > 0) then
                print("invalid command");
            end
            io.write(">");
        end-- if (in_line == "?")

		_scheduler.sleep_ms(250);
    end-- while (1) do
end-- function cpgwDrvMainApp()