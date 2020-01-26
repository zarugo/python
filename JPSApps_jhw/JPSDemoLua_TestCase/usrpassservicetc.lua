 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - UsrPassService Test Case               ");
    print("--------------------------------------------------");
    print("UsrPassServiceLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'   - To create the UsrPass instance");
    print("- 'it'   - Init to initialize UsrPass ");
    print("- 'st'   - Get tariffs status");
    print("- 'ds'   - Dispose the tariffs");
    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function usrpassServiceTC()

    local msg;
	local siteCode;
	local start_ts, end_ts, family, freeTime, exitTime;

    repeat
        msg = _scheduler.pend();
        print("usrpassServiceTC-> msg=", msg);
    until(msg == "usrpasssrv");
    printMenu();

    local usrpassSrv = UsrPassServiceLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = usrpassSrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json", "./Resources/AdditionalData.json");
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
			ret = usrpassSrv:init();
			print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "ds") then
            print("*** dispose ***");
            ret = usrpassSrv:dispose();
            print("dispose result: " .. ret);
		-------------------------------------------------------
         elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = usrpassSrv:status();
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
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("usrpassServiceTC-> msg=", msg);
            until(msg == "usrpasssrv");
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
end-- function usrpassServicePainApp()