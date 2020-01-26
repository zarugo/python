 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
-- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - GpioCtrlDriver Test Case               ");
    print("--------------------------------------------------");
    print("DisplayDriverLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'     - To create the Gpio Ctrl Driver Intsance");
    print("- 'it'     - To initialize the Gpio Ctrl Driver");
    print("- 'st'     - To get the Gpio Ctrl Driver status");
    print("- 'ds'     - To dispose the Gpio Ctrl Driver");
	print("- 'sp'     - To set an output pin value");	
    print("- 'pp'     - To pulse an output pin");
	print("- 'pa'     - To pulse all output pins");
    print("- 'som'    - To set many outputs using a mask");	
    print("- 'ss'     - To sense an input pin");

    print("- 'rt'     - To return to main menu.");
    print("");
    io.write(">");
end

 
-- gpioctrlDriver Corutine:
function gpioctrlDriverTC()

    local msg;
	local gpioctrlDrv;
	local statusTable;
	local senseTable;
	local ret;
	
    repeat
        msg = _scheduler.pend();
        print("gpioctrlDrvTC-> msg=", msg);
    until(msg == "gpioctrldrv");
    printMenu();

	gpioctrlDrv = GpioCtrlDriverLuaIF:new();
	
	while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
			print("*** create ***");
			ret = gpioctrlDrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
			print("create result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");		
			ret = gpioctrlDrv:init();
			print("init result: " .. ret);
       -------------------------------------------------------
        elseif (in_line == "ds") then
            print("*** dispose ***");
            ret = gpioctrlDrv:dispose();
            print("dispose result: " .. ret);
 		-------------------------------------------------------
        elseif (in_line == "st") then
			print("*** status ***");
			statusTable = gpioctrlDrv:status();
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
				print("InputsStatus = '" .. statusTable["InputsStatus"] .. "'");
				print("");
			end
		-------------------------------------------------------
        elseif (in_line == "sp") then
			print("*** set pin ***");
            print("Choose The Pin Id:");
            print("Min 0, max 31");
            print(">");
            local piId = tonumber(pop_lua_input());
            print("Input the Output Value (0=Low, 1=High):");
            print(">");
			local outVal = tonumber(pop_lua_input());
			ret = gpioctrlDrv:setPin(piId,outVal);
			print("set pin result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "pp") then
			print("*** pulse pin ***");
			-- Set---------(pinId   , pulseNo, startLowHigh, highPeriodMs,  lowPeriodMs)
			print("Choose The Pin Id:");
            print("Min 0, max 31 (default 0)");
            print(">");
            local piId = pop_lua_number(0);
            print("Input the pulses number");
			print("(Default 4)");
            print(">");
            local pulseNo = pop_lua_number(4);
            print("Input the start mode (0= Low, 1= High)");
            print("(Default High)");
            print(">");
            local startMode = pop_lua_number(1);
            print("Input the high period (in ms)");
			print("(Default 150 ms)");
            print(">");
            local highPrd = pop_lua_number(150);
            print("Input the low period (in ms)");
			print("(Default 150 ms)");
            print(">");
            local lowPrd = pop_lua_number(150);
			
			ret = gpioctrlDrv:pulsePin(piId,pulseNo,startMode,highPrd,lowPrd);
			print("pulse pin result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "pa") then
			print("*** pulse all pin ***");
			-- Set---------(pinId   , pulseNo, startLowHigh, highPeriodMs,  lowPeriodMs)
			print("Input the pulses number");
			print("(Default 4)");
            print(">");
            local pulseNo = pop_lua_number(4);
            print("Input the start mode (0= Low, 1= High)");
            print("(Default High)");
            print(">");
            local startMode = pop_lua_number(1);
            print("Input the high period (in ms)");
			print("(Default 150 ms)");
            print(">");
            local highPrd = pop_lua_number(150);
            print("Input the low period (in ms)");
			print("(Default 150 ms)");
            print(">");
            local lowPrd = pop_lua_number(150);
			for i=0,15 do
				ret = gpioctrlDrv:pulsePin(i,pulseNo,startMode,highPrd,lowPrd);
			end
			print("pulse all pin result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "som") then
            print("*** set out mask ***");
			local out_val="";
			local out_msk="";		
			print("Input the output values (eg. 000000FF):");
			print(">");
			out_val = pop_lua_input();
			print("Input the output mask (eg. 000000FF):");
			print(">");
			out_msk = pop_lua_input();
			ret = gpioctrlDrv:setOutMsk(out_val, out_msk);
			print("set out mask result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "ss") then
			print("*** sense ***");
			senseTable = gpioctrlDrv:sense(0);
			print("");
			print("--------------------------------------------------");
			print("Sense Result: ");
			if(senseTable ~= nil) then
				print("PinId     = '" .. senseTable["PinId"] .. "'");
				print("EventType = '" .. senseTable["EventType"] .. "'");
				print("");
				_scheduler.publish(senseTable);
			end	
      -------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("gpioctrlDrvTC-> msg=", msg);
            until(msg == "gpioctrldrv");
            printMenu();
		-------------------------------------------------------
        else
           if (string.len(in_line) > 0) then
                print("invalid command");
            end
            io.write(">");
        end-- if (in_line == "?")
		-------------------------------------------------------
	end-- while (1) do
end-- function gpioctrlDriverTC()