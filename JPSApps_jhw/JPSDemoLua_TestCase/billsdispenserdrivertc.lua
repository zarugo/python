 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - Bills Dispenser Driver Test Case     ");
    print("--------------------------------------------------");
    print("BillsDispenserDriverLuaIF Menu:");
    print("To display menu press '?'.");
    print("");
    print("*** Commands ***");
    print("- 'cr'     - To create the BillsDispenser Intsance");
    print("- 'it'     - To initialize the BillsDispenser");
    print("- 'st'     - To get the BillsDispenser status");
    print("- 'ds'     - To dispose the BillsDispenser");
    print("- 'da'     - To dispense Amount");
    print("- 'cb'     - To count Bills");

    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function billsdispenserDriverTC()

    local msg;

    repeat
        msg = _scheduler.pend();
        print("BillsDispenserDriver-> msg=", msg);
    until(msg == "billsdispenserdrv");
    printMenu();

    local billsDispObj = BillsDispenserDriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
			print("Enter currency(EUR, USD ...)");
			in_line = pop_lua_input();
			if (tostring(in_line) ~= nil) then
                ret = billsDispObj:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json", tostring(in_line));
                print("create result: " .. ret);
            else
                print("invalid option");
            end;
		-------------------------------------------------------
        elseif (in_line == "it") then
			print("*** init ***");
            ret = billsDispObj:init();
            print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = billsDispObj:status();
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
            ret = billsDispObj:dispose();
            print("dispose result: " .. ret);
      -------------------------------------------------------
        elseif (in_line == "da") then
            print("*** dispense amount***");
			print("Enter amount to be dispensed:");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
                ret = billsDispObj:dispAmount(tonumber(in_line));
                 print("dispense result: " .. ret);
            else
                print("invalid option");
            end;    
      -------------------------------------------------------
        elseif (in_line == "cb") then
            print("*** count bills ***");
			billsQty={0};
			local i=1;
			
			while(i<5) do
				print("Enter the quantity for bill-" .. tostring(i) .. ":");
				print(">");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					billsQty[i] = tonumber(in_line);
					print("input-" .. tostring(i) .. "=" .. tostring(billsQty[i]));
					i=i+1;
				else
					print("invalid input");
				end;	
            end
			
			ret =  billsDispObj:countBills(billsQty);
			print("count bills result: " .. ret);
            
      -------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("BillsDispenserDriver-> msg=", msg);
            until(msg == "billsdispenserdrv");
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
end-- function billsdispenserDriverTC()