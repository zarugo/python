 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - Ethernet Barrier Test Case               ");
    print("--------------------------------------------------");
    print("BarrierDriverLuaIF Menu:");
	  print("To display menu press '?'.");
	  print("");
	  print("*** Commands ***");
    print("- 'cr'     - To create the Barrier Intsance");
    print("- 'it'     - To initialize the Barrier");
    print("- 'st'     - To get the Barrier status");
    print("- 'ds'     - To dispose the Barrier");
    print("- 'op'     - To open the Barrier");
    print("- 'cl'     - To close the Barrier");
    print("- 'hp'     - To open the Barrier in High Priority Mode");
    print("- 'ex'     - To exit the High Priority Mode");

    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function barrierDriverTC()

   local msg;
	
    repeat
        msg = _scheduler.pend();
        print("barrierDrvTC-> msg=", msg);
    until(msg == "barrierdrv");
    printMenu();

    local barrierDrv = BarrierDriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = barrierDrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
            print("create result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
            ret = barrierDrv:init();
            print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = barrierDrv:status();
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
            ret = barrierDrv:dispose();
            print("dispose result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "op") then
            print("*** open ***");
            ret = barrierDrv:openBarrier();
            print("open result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "cl") then
            print("*** close ***");
            ret = barrierDrv:closeBarrier();
            print("close result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "hp") then
            print("*** open the Barrier in High Priority Mode ***");
            ret = barrierDrv:openHighPriorityBarrier();
            print("open (High Priority Mode) result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "ex") then
            print("*** exit the High Priority Mode ***");
            ret = barrierDrv:delCmdBarrier();
            print("exit (High Priority Mode) result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "rt") then
                print("*** return ***");
                _scheduler.publish("return");
            repeat
                msg = _scheduler.pend();
                print("barrierDrvTC-> msg=", msg);
            until(msg == "barrierdrv");
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
end-- function barrierDriverTC()