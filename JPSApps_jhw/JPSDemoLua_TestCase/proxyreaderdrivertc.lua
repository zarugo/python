 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - ProxyReaderDriver Test Case               ");
    print("--------------------------------------------------");
    print("ProxyReaderDriverLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'     - To create the ProxyReader Intsance");
    print("- 'it'     - To initialize the ProxyReader");
    print("- 'st'     - To get the ProxyReader status");
    print("- 'ds'     - To dispose the printer");
    print("- 'sca'    - To scan a bar code data");

    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function proxyreaderDriverTC()

    local msg;

    repeat
        msg = _scheduler.pend();
        print("proxyreaderDrvTC-> msg=", msg);
    until(msg == "proxyreaderdrv");
    printMenu();

    local proxyreaderDrv = ProxyReaderDriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = proxyreaderDrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
            print("create result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
            ret = proxyreaderDrv:init();
            print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = proxyreaderDrv:status();
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
            ret = proxyreaderDrv:dispose();
            print("dispose result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "sca") then
            print("*** scan barcode ***");
                local bcData = proxyreaderDrv:scan();
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
                print("proxyreaderDrvTC-> msg=", msg);
            until(msg == "proxyreaderdrv");
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
end-- function proxyreaderDrvMainApp()