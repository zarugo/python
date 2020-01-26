 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - BCReaderDriver Test Case               ");
    print("--------------------------------------------------");
    print("BCReaderDriverLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'     - To create the BCReader Intsance");
    print("- 'it'     - To initialize the BCReader");
    print("- 'st'     - To get the BCReader status");
    print("- 'ds'     - To dispose the printer");
    print("- 'sca'    - To scan a bar code data");

    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function bcreaderDriverTC()

    local msg;

    repeat
        msg = _scheduler.pend();
        print("bcreaderServTC-> msg=", msg);
    until(msg == "bcreaderdrv");
    printMenu();

    local bcreaderServ = BCReaderDriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = bcreaderServ:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
            print("create result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
            ret = bcreaderServ:init();
            print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = bcreaderServ:status();
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
            ret = bcreaderServ:dispose();
            print("dispose result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "sca") then
            print("*** scan barcode ***");
                local bcData = bcreaderServ:scan();
            if((bcData ~= nil) and string.len(bcData)>0) then
                print("bcData:", bcData);
            else
                print("No BC data acquired.");
            end;
      -------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("bcreaderServTC-> msg=", msg);
            until(msg == "bcreaderdrv");
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
end-- function bcreaderServMainApp()