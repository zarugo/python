 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - ProxyRdrWrtrDriver Test Case               ");
    print("--------------------------------------------------");
    print("ProxyRdrWrtrDriverLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'     - To create the ProxyReader Intsance");
    print("- 'it'     - To initialize the ProxyReader");
    print("- 'st'     - To get the ProxyReader status");
    print("- 'ds'     - To dispose the printer");
    print("- 'wrd'    - To dwrite data");
    print("- 'sca'    - To read data");

    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function proxyrdrwrtrDriverTC()

    local msg;

    repeat
        msg = _scheduler.pend();
        print("proxyrdrwrtrDrvTC-> msg=", msg);
    until(msg == "proxyrdrwrtrdrv");
    printMenu();

    local proxyrdrwrtrDrv = ProxyRdrWrtrDriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = proxyrdrwrtrDrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
            print("create result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
            ret = proxyrdrwrtrDrv:init();
            print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = proxyrdrwrtrDrv:status();
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
            ret = proxyrdrwrtrDrv:dispose();
            print("dispose result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "wrd") then
            print("*** write data ***");
                local bcData = proxyrdrwrtrDrv:wrdata("TEST");
            if((bcData ~= nil) and string.len(bcData)>0) then
                print("bcData:", bcData);
            else
                print("No BC data acquired.");
            end;
        -------------------------------------------------------
        elseif (in_line == "sca") then
            print("*** read data ***");
                local bcData = proxyrdrwrtrDrv:scan();
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
                print("proxyrdrwrtrDrvTC-> msg=", msg);
            until(msg == "proxyrdrwrtrdrv");
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
end-- function proxyrdrwrtrDrvMainApp()