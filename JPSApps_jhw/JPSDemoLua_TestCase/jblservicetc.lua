 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - JBLService Test Case               ");
    print("--------------------------------------------------");
    print("JBLServiceLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'  - To create the JBL instance");
    print("- 'it'  - Init to initialize JBL ");
    print("- 'st'  - Get jbl status");
    print("- 'ds'  - Dispose the jbl");
	print("- 'op'  - Trigger jbl operations");
    print("- 'rt'  - To return to main menu.");
    print("");
    io.write(">");
end

 -- Prints available operations to the console:
local function printOps()
    print("");
    print("Input the operation type param: ");
	print("1  = alrm,  2  = lane,  3  = rebt,   4  = upas,");
	print("5  = trns,  6  = olgn,  7  = cash,   8  = opac,");
	print("9  = mony,  10 = card,  11 = payc,   12 = chng,");
	print("13 = crnt,  14 = auth,  15 = stat,   16 = vldn,");
	print("17 = rslt,  18 = pnck,  19 = plst,   rt = Return");
    io.write(">");
end

 -- Operators Management:
local function topMngmt(jblSrv)
	local in_line, op = 1, ret;
    print("*** trigger operation ***");
	while(in_line ~= "rt") do
		printOps();
		in_line = pop_lua_input();
		if (tonumber(in_line) ~= nil) then
			op = tonumber(in_line);
			ret = jblSrv:trigop(op);
		else
			if(in_line ~= "rt") then print("invalid op type"); end
		end;		
	end
end

-- Main Application Corutine:
function jblServiceTC()
    local msg, ret, in_line, statusTable, op;
	local statusTable, alarmListTable, sensorListTable;
	
    repeat
        msg = _scheduler.pend();
        print("jblServiceTC-> msg=", msg);
    until(msg == "jblsrv");
    printMenu();

    local jblSrv = JBLServiceLuaIF:new();

    while (1) do        
        in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = jblSrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
			ret = jblSrv:init();
			print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "ds") then
            print("*** dispose ***");
            ret = jblSrv:dispose();
            print("dispose result: " .. ret);
		-------------------------------------------------------
         elseif (in_line == "st") then
            print("*** status ***");
            statusTable = jblSrv:status();
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
        elseif (in_line == "op") then
			topMngmt(jblSrv);
			printMenu();
		-------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("jblServiceTC-> msg=", msg);
            until(msg == "jblsrv");
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
end-- function jblServicePainApp()