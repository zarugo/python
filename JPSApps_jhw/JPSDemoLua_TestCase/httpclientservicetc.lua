 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - HttpClientService Test Case               ");
    print("--------------------------------------------------");
    print("HttpClientServiceLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'  - To create the HttpClient instance");
    print("- 'it'  - Init to initialize HttpClient ");
    print("- 'st'  - Get HttpClient status");
    print("- 'ds'  - Dispose the HttpClient");
    print("- 'sr'  - Send an HttpClient Request");
    print("- 'rt'  - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function httpClientServiceTC()

    local msg;

    repeat
        msg = _scheduler.pend();
        print("httpClientServiceTC-> msg=", msg);
    until(msg == "httpclientsrv");
    printMenu();

    local httpClientSrv = HttpClientServiceLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = httpClientSrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
			ret = httpClientSrv:init();
			print("init result: " .. ret);
		-------------------------------------------------------
         elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = httpClientSrv:status();
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
            print("*** sendRequest ***");

            local method ="";
			local uri = "";
			local body = "";

            print("Choose The Request Type:");
            print("0) FOR A GET REQUEST");
            print("1) FOR A POST REQUEST");
            print(">");
			method = pop_lua_input();
			
            if ((tonumber(method) ~= nil) and (tonumber(method) <=1 )) then
				print("Input the string to be used as request uri: ");		
				print("(i.e. '[IP:PORT]/url')");
				uri = pop_lua_input();
				if(method == "1") then
					print("Input the string to be used as request body: ");
					body = pop_lua_input();
				end
				ret = httpClientSrv:sendHttpReq(method,uri,body);
            else
                print("invalid option");
            end;
                        
            print("sendRequest result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "ds") then
            print("*** dispose ***");
            ret = httpClientSrv:dispose();
            print("dispose result: " .. ret);
		-------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("httpClientServiceTC-> msg=", msg);
            until(msg == "httpclientsrv");
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
end-- function httpClientServicePainApp()