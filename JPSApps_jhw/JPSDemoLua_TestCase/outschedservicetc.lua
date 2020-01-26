 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - OutSchedService Test Case               ");
    print("--------------------------------------------------");
    print("OutSchedServiceLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'   - To create the OutSched instance");
    print("- 'it'   - Init to initialize OutSched ");
    print("- 'st'   - Get outsched status");
    print("- 'ds'   - Dispose the outsched");
    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function outschedServiceTC()

    local msg;
	local siteCode;
	local start_ts, end_ts, family, freeTime, exitTime;

    repeat
        msg = _scheduler.pend();
        print("outschedServiceTC-> msg=", msg);
    until(msg == "outschedsrv");
    printMenu();

    local outschedSrv = OutSchedServiceLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = outschedSrv:create("./Resources/www/webcfgtool/outsched/ConfigData.json");
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
			ret = outschedSrv:init();
			print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "ds") then
            print("*** dispose ***");
            ret = outschedSrv:dispose();
            print("dispose result: " .. ret);
		-------------------------------------------------------
         elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = outschedSrv:status();
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
                print("outschedServiceTC-> msg=", msg);
            until(msg == "outschedsrv");
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
end-- function outschedServicePainApp()