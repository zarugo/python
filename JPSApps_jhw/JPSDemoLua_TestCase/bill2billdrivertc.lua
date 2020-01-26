 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - Bill2BillDriver Test Case               ");
    print("--------------------------------------------------");
    print("Bill2BillDriverLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'     - To create the Bill2Bill instance");
    print("- 'it'     - To initialize the Bill2Bill device");
    print("- 'st'     - To get the status of the Bill2Bill device");
    print("- 'ds'     - To dispose the Bill2Bill instance");
    print("- 'pl'     - To poll the Bill2Bill device");
    print("- 'bt'     - To get the bill table of the Bill2Bill device");
    print("- 'eb'     - To enable the bill types of the Bill2Bill device");
	print("- 'db'     - To disable all bill types of the Bill2Bill device");
	print("- 'dp'     - To dispense bills");
	print("- 'cs'     - To get the cassette status");
	print("- 'un'     - To unload the cassette");

    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function bill2billDriverTC()

    local msg;

    repeat
        msg = _scheduler.pend();
        print("Bill2BillDrvTC-> msg=", msg);
    until(msg == "bill2billdrv");
    printMenu();

    local Bill2BillDrv = Bill2BillDriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = Bill2BillDrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json", "./Resources/AdditionalData.json");
            print("create result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "it") then
			print("*** init ***");
            ret = Bill2BillDrv:init();
            print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = Bill2BillDrv:status();
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
            ret = Bill2BillDrv:dispose();
            print("dispose result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pl") then
            print("*** poll ***");
            local state = Bill2BillDrv:poll();  
            if((state ~= nil) and string.len(state)>0) then
                print("Bill2Bill current state: ", state);
            else
                print("Bill2Bill current state could NOT be acquired!");
            end;
		-------------------------------------------------------
        elseif (in_line == "bt") then
            print("*** get the bill table ***");
			local bill_table = Bill2BillDrv:getBillTable();  
            if((bill_table ~= nil) and string.len(bill_table)>0) then
                print("Bill2Bill bill table:\r\n" .. bill_table);
            else
                print("Bill2Bill bill table could NOT be acquired!");
            end;
		-------------------------------------------------------
        elseif (in_line == "eb") then
            print("*** enable the bill types ***");
			print("Enter Accepting Option: 1 - AcceptingContinuously, 2 - AcceptingOneBill");
			in_line = pop_lua_input();
			in_line_num = tonumber(in_line);
			if ( in_line_num ~= nil and (in_line_num == 1 or in_line_num == 2)) then
                ret = Bill2BillDrv:setBillTypes(in_line_num);
                print("enable the bill types result: " .. ret);
            else
                print("invalid option");
            end;
		-------------------------------------------------------
        elseif (in_line == "db") then
            print("*** disable all bill types ***");
            ret = Bill2BillDrv:disableBillTypes();
            print("disable all bill types result: " .. ret);
         -------------------------------------------------------
        elseif (in_line == "re") then
            print("*** reset ***");
            ret = Bill2BillDrv:reset();
            print("reset result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "dp") then
            print("*** dispense ***");
			billsQty={0};
			local i=1;
			print("Press 'x' to exit.");
			while(1) do
				print("value: ");
				print(">")
				in_line = pop_lua_input();
				if(in_line == "x")  then break; end;
				if (tonumber(in_line) ~= nil) then
					billsQty[i] = tonumber(in_line);
					i=i+1;
				else
					print("invalid input");
				end;	

				print("count: ");
				print(">")
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					billsQty[i] = tonumber(in_line);
					i=i+1;
				else
					print("invalid input");
				end;
            end
            ret = Bill2BillDrv:dispense(billsQty);
            print("dispense result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "cs") then
            print("*** cassette status ***");
			local cass_status = Bill2BillDrv:cassStatus();  
            if((cass_status ~= nil) and string.len(cass_status)>0) then
                print("Bill2Bill cassette status:\r\n" ..cass_status);
            else
                print("Bill2Bill cassette status could NOT be acquired!");
            end;
        -------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("Bill2BillDrvTC-> msg=", msg);
            until(msg == "bill2billdrv");
            printMenu();
		-------------------------------------------------------
		elseif (in_line == "un") then
            print("*** unload ***");
			billsQty={0};
			local i=1;
			while(1) do
				print("enter denomination value: ");
				print(">")
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					billsQty[i] = tonumber(in_line);
					i=i+1;
				else
					print("invalid input");
				end;	

				print("enter remaining bills count: ");
				print(">")
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					billsQty[i] = tonumber(in_line);
					i=i+1;
					break;
				else
					print("invalid input");
				end;
            end
            ret = Bill2BillDrv:unload(billsQty);
            print("unload result: " .. ret);
		-------------------------------------------------------
        else
           if (string.len(in_line) > 0) then
                print("invalid command");
            end
            io.write(">");
        end-- if (in_line == "?")

		_scheduler.sleep_ms(250);
    end-- while (1) do
end-- function Bill2BillDrvMainApp()