 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - BLEDriver Test Case               ");
    print("--------------------------------------------------");
    print("BLEDriverLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'     - To create the BLE Intsance");
    print("- 'it'     - To initialize the BLE");
    print("- 'st'     - To get the device status");
    print("- 'ds'     - To dispose the printer");
	print("- 'rst'    - To reset the BLE device");
    print("- 'trg'    - To execute a 'Trigger APM' command");
    print("- 'etr'    - To execute a 'End Transaction' command ");
    print("- 'vrs'    - To execute a 'Verify Result' command ");
    print("- 'stt'    - To execute a 'Start Transit' command ");
    print("- 'edt'    - To execute a 'End Transit' command ");
    print("- 'tem'    - To execute a 'Ticket Emission' command ");
	
    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function bleDriverTC()

    local msg;

    repeat
        msg = _scheduler.pend();
        print("bleDrvTC-> msg=", msg);
    until(msg == "bledrv");
    printMenu();

    local bleDrv = BLEDriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = bleDrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
            print("create result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
            ret = bleDrv:init();
            print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = bleDrv:status();
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
            ret = bleDrv:dispose();
            print("dispose result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "rst") then
            print("*** reset ***");
            ret = bleDrv:reset();
            print("reset result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "trg") then
            print("*** trigAPM ***");
            print("Input the UID parameter:");
            print(">");
            in_line = pop_lua_input();
            if (in_line ~= nil) then
                ret = bleDrv:trigAPM(in_line);
                print("park result: " .. ret);
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "etr") then
            print("*** endTransaction ***");
            print("Choose The Ticket Error Code:");
            print("Min 0 ('TicketErrOk'), max 20 ('TicketErrBlePrblm')");
            print(">");
            local tckErrCode = tonumber(pop_lua_input());
            print("Input the 'Time To Exit' in minutes:");
            print(">");
            local timeToExit = tonumber(pop_lua_input());
            print("Input the 'amount':");
            print(">");
            local amount = tonumber(pop_lua_input());
            print("Input the 'currency':");
            print(">");
            local currency = pop_lua_input();
			ret = bleDrv:endTransaction(tckErrCode,timeToExit,amount,currency);
            print("endTransaction result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "vrs") then
            print("*** verifyRes ***");
            print("Choose The Ticket Error Code:");
            print("Min 0 ('TicketErrOk'), max 20 ('TicketErrBlePrblm')");
            print(">");
            in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                ret = bleDrv:verifyRes(tonumber(in_line));
                print("verifyRes result: " .. ret);
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "stt") then
            print("*** startTransit ***");
            ret = bleDrv:startTransit();
            print("startTransit result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "edt") then
            print("*** endTransit ***");
            print("Choose The endTransit Mode:");
            print("0) Normal Gate Crossing");
            print("1) Gone Backward");
			print("2) Undetermined");
            print(">");
			in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                ret = bleDrv:endTransit(tonumber(in_line));
                print("endTransit result: " .. ret);
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "tem") then
            print("*** endTransaction ***");
			local devType, tckErrCode, tckType, gmtOffs, tmStmp, tckData, tm2Exit, amount;
            print("Choose The Device Type:");
            print("0) Entrance or Exit");
			print("1) APM");
            print(">");
			devType = tonumber(pop_lua_input());
            print("Choose The Ticket Error Code:");
            print("Min 0 ('TicketErrOk'), max 20 ('TicketErrBlePrblm')");
            print(">");
            tckErrCode = tonumber(pop_lua_input());
            print("Choose the Ticket Type (0= Transient to 8=Undefined):");
            print(">");
            tckType = tonumber(pop_lua_input());
			print("Input the 'GMT Offset':");
            print(">");
			gmtOffs = pop_lua_input();
			print("Input the 'Ticket Data' as 22 char string:");
            print(">");
            tckData = pop_lua_input();
			
			tm2Exit = 0;
			amount = 0;
			
			if(devType == 1) then
				devType = 4;
				print("Input the 'Time To Exit' in minutes:");
				print(">");
				tm2Exit = tonumber(pop_lua_input());
				print("Input the 'Amount':");
				print(">");
				amount = tonumber(pop_lua_input());
			end

            ret = bleDrv:ticketEmission(devType, tckErrCode, tckType, gmtOffs, os.time(), tckData, tm2Exit, amount);
            print("ticketEmission result: " .. ret);
        -------------------------------------------------------
 		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("bleDrvTC-> msg=", msg);
            until(msg == "bledrv");
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
end-- function bleDrvMainApp()