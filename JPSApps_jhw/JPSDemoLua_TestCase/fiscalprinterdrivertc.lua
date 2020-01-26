 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - Fiscal Printer Test Case               ");
    print("--------------------------------------------------");
    print("FiscalPrinterDriverLuaIF Menu:");
	  print("To display menu press '?'.");
	  print("");
	  print("*** Commands ***");
    print("- 'cr'     - To create the Fiscal Printer Intsance");
    print("- 'it'     - To initialize the Fiscal Printer");
    print("- 'st'     - To get the Fiscal Printer status");
    print("- 'ds'     - To dispose the Fiscal Printer");
    print("- 'pi'     - To print info for the Fiscal Printer");
    print("- 'id'     - To get the ID of the Fiscal Printer");
    print("- 'gd'     - To get date and time of the Fiscal Printer");
    print("- 'sd'     - To set date and time of the Fiscal Printer");
    print("- 'pr'     - To print test fiscal receipt for Cash payment");
    print("- 'pl'     - To print test fiscal receipt for Lost Ticket");
    print("- 'rx'     - To print daily X report (NO ZEROING)");
    print("- 'rz'     - To print daily Z report (WITH ZEROING)");
    print("- 'rm'     - To print report for the previous month");
    print("- 'ry'     - To print report for the previous year");
    print("- 'fl'     - To feed line");
    print("- 'dr'     - To duplicate the last fiscal receipt");
    print("- 'fm'     - To get the free fiscal memory of the Fiscal Printer");
    print("- 'mc'     - To get the money present in cash");
    print("- 'am'     - To adjust money (add/remove money)");

    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function fiscalprinterDriverTC()

   local msg;
	
    repeat
        msg = _scheduler.pend();
        print("fiscalprinterDrvTC-> msg=", msg);
    until(msg == "fiscalprinterdrv");
    printMenu();

    local fiscalprinterDrv = FiscalPrinterDriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = fiscalprinterDrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
            print("create result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
            ret = fiscalprinterDrv:init();
            print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = fiscalprinterDrv:status();
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
            ret = fiscalprinterDrv:dispose();
            print("dispose result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pi") then
            print("*** print info ***");
            local printerInfo = fiscalprinterDrv:printInfo();
            if((printerInfo ~= nil) and string.len(printerInfo)>0) then
                print("***Printer Information: ", printerInfo);
            else
                print("***No Printer Information");
            end;
        -------------------------------------------------------
        elseif (in_line == "id") then
            print("*** get printer id ***");
            local printerID = fiscalprinterDrv:getPrinterID();
            if((printerID ~= nil) and string.len(printerID)>0) then
                print("***Printer ID received: ", printerID);
            else
                print("***No Printer ID received");
            end;
        -------------------------------------------------------
        elseif (in_line == "gd") then
            print("*** get date and time ***");
            local printerDateTime = fiscalprinterDrv:getDateTime();
            if((printerDateTime ~= nil) and string.len(printerDateTime)>0) then
                print("***Printer Date and Time received: ", printerDateTime);
            else
                print("***No Printer Date and Time received");
            end;
        -------------------------------------------------------
        elseif (in_line == "sd") then
            print("*** set date and time ***");
            ret = fiscalprinterDrv:setDateTime();
            print("set date and time result: " .. ret);
            -------------------------------------------------------
        elseif (in_line == "pr") then
            print("*** print test fiscal receipt for Cash payment ***");
            print("Enter the total amount of the test fiscal receipt:");
            in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                ret = fiscalprinterDrv:printReceipt(tonumber(in_line));
                print("Result: " .. ret);
            else
                print("invalid option");
            end;
            -------------------------------------------------------
        elseif (in_line == "pl") then
            print("*** print test fiscal receipt for Lost Ticket ***");
            print("Enter the total amount of the test fiscal receipt:");
            in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                ret = fiscalprinterDrv:printLostTktReceipt(tonumber(in_line));
                print("Result: " .. ret);
            else
                print("invalid option");
            end;
            -------------------------------------------------------
        elseif (in_line == "rx") then
            print("*** print daily X report (NO ZEROING) ***");
            ret = fiscalprinterDrv:printDailyXreport();
            print("Result: " .. ret);
            -------------------------------------------------------
        elseif (in_line == "rz") then
            print("*** print daily Z report (WITH ZEROING) ***");
            ret = fiscalprinterDrv:printDailyZreport();
            print("Result: " .. ret);
            -------------------------------------------------------
        elseif (in_line == "rm") then
            print("*** print report for the previous month ***");
            ret = fiscalprinterDrv:printMonthlyReport();
            print("Result: " .. ret);
            -------------------------------------------------------
        elseif (in_line == "ry") then
            print("*** print report for the previous year ***");
            ret = fiscalprinterDrv:printYearlyReport();
            print("Result: " .. ret);
            -------------------------------------------------------
        elseif (in_line == "fl") then
            print("*** feed line ***");
            print("Enter number of lines to be printed:");
            in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                ret = fiscalprinterDrv:feedLine(tonumber(in_line));
                print("Result: " .. ret);
            else
                print("invalid option");
            end;
            -------------------------------------------------------
        elseif (in_line == "dr") then
            print("*** duplicate last receipt ***");
            ret = fiscalprinterDrv:duplicateLastRcp();
            print("Result: " .. ret);
            -------------------------------------------------------
        elseif (in_line == "fm") then
            print("*** get free fiscal memory ***");
            local printerFMInfo = fiscalprinterDrv:getFreeFiscMem();
            if((printerFMInfo ~= nil) and string.len(printerFMInfo)>0) then
                print("***Printer Information: ", printerFMInfo);
            else
                print("***No Information for Printer Fiscal Memory Fields");
            end;
            -------------------------------------------------------
        elseif (in_line == "mc") then
            print("*** get money present in cash ***");
            local printerCashInfo = fiscalprinterDrv:getMoneyInCash();
            if((printerCashInfo ~= nil) and string.len(printerCashInfo)>0) then
                print("***Printer Information: ", printerCashInfo);
            else
                print("***No Information for money present in Cash");
            end;
            -------------------------------------------------------
        elseif (in_line == "am") then
            print("*** adjust money (add/remove money)***");
            print("Enter amount (positive/negative) to be adjusted:");
            in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                ret = fiscalprinterDrv:adjustMoney(tonumber(in_line));
                print("Result: " .. ret);
            else
                print("invalid option");
            end;
            -------------------------------------------------------
        elseif (in_line == "pt") then
            print("*** print text line ***");
            ret = fiscalprinterDrv:printTextLine();
            print("Result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "rt") then
                print("*** return ***");
                _scheduler.publish("return");
            repeat
                msg = _scheduler.pend();
                print("fiscalprinterDrvTC-> msg=", msg);
            until(msg == "fiscalprinterdrv");
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
end-- function fiscalprinterDriverTC()