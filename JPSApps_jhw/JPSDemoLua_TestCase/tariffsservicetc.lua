 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - TariffsService Test Case               ");
    print("--------------------------------------------------");
    print("TariffsServiceLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'   - To create the Tariffs instance");
    print("- 'it'   - Init to initialize Tariffs ");
    print("- 'st'   - Get tariffs status");
    print("- 'ds'   - Dispose the tariffs");
	print("- 'ct'   - Calculate tariff");
    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function tariffsServiceTC()

    local msg;
	local siteCode;
	local start_ts, end_ts, family, freeTime, exitTime;

    repeat
        msg = _scheduler.pend();
        print("tariffsServiceTC-> msg=", msg);
    until(msg == "tariffssrv");
    printMenu();

    local tariffsSrv = TariffsServiceLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = tariffsSrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");

			print("Input siteCode param  ('0' to use siteCode from config file): ");
			print(">");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
				siteCode = tonumber(in_line)
				ret = tariffsSrv:init(siteCode);
				print("init result: " .. ret);
			else
				print("invalid freeTime");
			end;
		-------------------------------------------------------
        elseif (in_line == "ds") then
            print("*** dispose ***");
            ret = tariffsSrv:dispose();
            print("dispose result: " .. ret);
		-------------------------------------------------------
         elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = tariffsSrv:status();
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
        elseif (in_line == "ct") then
            print("*** compute tariff ***");
			print("Input the start_ts param (since unix epoch in ms): ");
            print(">");
            in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
                start_ts = tonumber(in_line)
                print("Input the end_ts param (since unix epoch in ms): ");
                print(">");
                in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					end_ts = tonumber(in_line)
					print("Input the family param: ");
					print("0 = Transient, 1 = Subscription, 2 = Pre-Paid, 3 = Value Voucher, 4 = Time Voucher, 5 = Congress card");
					print(">");
					in_line = pop_lua_input();
					if (tonumber(in_line) ~= nil) then
						family = tonumber(in_line)
						print("Input free time param (0,1): ");
						print(">");
						in_line = pop_lua_input();
						if (tonumber(in_line) ~= nil) then
							freeTime = tonumber(in_line)
							print("Input exit time param (0,1): ");
							print(">");
							in_line = pop_lua_input();
							if (tonumber(in_line) ~= nil) then
								exitTime = tonumber(in_line)
								local ctRes = tariffsSrv:tarCalc(start_ts,end_ts,family,freeTime,exitTime);
								print("tarCalc result:");
								
								if(ctRes ~= nil) then
									print("result        ", "'" .. ctRes["result"] .. "'");
									print("retCode       ", "'" .. ctRes["retCode"] .. "'");
									print("freeTime      ", "'" .. ctRes["freeTime"] .. "'");
									print("exitTime      ", "'" .. ctRes["exitTime"] .. "'");
									print("timeLeft      ", "'" .. ctRes["timeLeft"] .. "'");
									print("");
								else
									print("invalid ctRes");
								end;						
							else
								print("invalid exitTime");
							end;
						else
							print("invalid freeTime");
						end;
					else
						print("invalid family");
					end;
				else
					print("invalid end_ts ");
				end;
            else
                print("invalid start_ts");
            end;
		-------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("tariffsServiceTC-> msg=", msg);
            until(msg == "tariffssrv");
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
end-- function tariffsServicePainApp()