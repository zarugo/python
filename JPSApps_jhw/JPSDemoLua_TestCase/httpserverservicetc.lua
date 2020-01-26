 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - HttpServerService Test Case               ");
    print("--------------------------------------------------");
    print("HttpServerServiceLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'  - To create the HttpServer instance");
    print("- 'it'  - Init to initialize HttpServer ");
    print("- 'st'  - Get HttpServer status");
    print("- 'ds'  - Dispose the HttpServer");
    print("- 'sr'  - Send an HttpServer Response");
    print("- 'rt'  - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function httpServerServiceTC()

    local msg;

    repeat
        msg = _scheduler.pend();
        print("httpServerServiceTC-> msg=", msg);
    until(msg == "httpserversrv");
    printMenu();

    local httpServerSrv = HttpServerServiceLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = httpServerSrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
			ret = httpServerSrv:init();
			print("init result: " .. ret);
		-------------------------------------------------------
         elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = httpServerSrv:status();
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
        elseif (in_line == "sr") then
            print("*** sendResponse ***");
            print("Input the string to be used as response body: ");            
            in_line = pop_lua_input();
			
			ret = httpServerSrv:sendHttpResp(in_line);
            print("sendResponse result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "ds") then
            print("*** dispose ***");
            ret = httpServerSrv:dispose();
            print("dispose result: " .. ret);
		-------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("httpServerServiceTC-> msg=", msg);
            until(msg == "httpserversrv");
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
end-- function httpServerServicePainApp()