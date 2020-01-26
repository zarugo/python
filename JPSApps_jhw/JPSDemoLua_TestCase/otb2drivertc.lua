 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - OTB2Driver Test Case               ");
    print("--------------------------------------------------");
    print("OTB2DriverLuaIF Menu:");
    print("To display menu press '?'.");
    print("");
    print("*** Commands ***");
    print("- 'cr'     - To create the OTB2 Intsance");
    print("- 'it'     - To initialize the OTB2");
    print("- 'st'     - To get the OTB2 status");
    print("- 'ds'     - To dispose the printer");
    print("- 'fd'     - To feed a ticket from the rear feeder");
    print("- 're'     - To reset the device");
    print("- 'ej'     - To eject a ticket");
    print("- 'pk'     - To park a ticket into one of the OTB2 parking slots");
    print("- 'rs'     - To resume a previously parked ticket");
    print("- 'fld'    - To load a ticket from frontal loader");
    print("- 'sca'    - To scan the number of bar codes for all pre-configured ROI areas");
    print("- 'scx'    - To scan the data of bar codes for a specific ROI-x areas");
    print("- 'pjd'    - To print a JPSDemo ticket");
    print("- 'pje'    - To print a JPSEntry ticket");
    print("- 'pjp'    - To print a JPSPay ticket");
    print("- 'pjx'    - To print a JPSExit ticket");
    print("- 'pjr'    - To print a JPSReceipt ticket");
    print("- 'ppr'    - To print a JPSPosReceipt ticket");
    print("- 'pcs'    - To print a JPSCashSnapshot ticket");
    print("- 'pim'    - To print a JPSImage ticket");
    print("- 'pjc'    - To print a JPSCreditNote ticket");
    print("- 'pjl'    - To print a JPSLost ticket");
    print("- 'pjs'    - To print a JPSSubscr ticket");
    print("- 'pnt'    - To print n JPSDemo ticket");
    print("- 'fer'    - To execute feed emit retire cycle ");
    print("- 'cd'     - To execute a custom data access");

    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function otb2DriverTC()

    local msg;

    repeat
        msg = _scheduler.pend();
        print("otb2DrvTC-> msg=", msg);
    until(msg == "otb2drv");
    printMenu();

    local otb2Drv = OTB2DriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
        -------------------------------------------------------
        if (in_line == "?") then
            printMenu();
        -------------------------------------------------------
        elseif (in_line == "cr") then
            print("*** create ***");            
            print("Choose The Config Mode:");
            print("0) Start using last loaded configurations");
            print("1) Erease and load current configurations");
            in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                ret = otb2Drv:create(tonumber(in_line),"./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json", "./Resources/AdditionalData.json");
                print("create result: " .. ret);
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
            ret = otb2Drv:init();
            print("init result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = otb2Drv:status();
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
            ret = otb2Drv:dispose();
            print("dispose result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "fd") then
            print("*** feed ***");
            ret = otb2Drv:feed();
            print("feed result: " .. ret);
         -------------------------------------------------------
        elseif (in_line == "re") then
            print("*** reset ***");
            ret = otb2Drv:reset();
            print("reset result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "ej") then
            print("*** eject ***");            
            print("Choose The Eject Mode:");
            print("0) FRONTAL PARTIAL");
            print("1) FRONTAL FULL");
            print("2) REAR FULL");
            print("3) BOTTOM FULL");
            print(">");
            in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                ret = otb2Drv:eject(tonumber(in_line));
                print("eject result: " .. ret);
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "pk") then
            print("*** park ***");
            print("Choose The Park Mode:");
            print("0) PARKING TO BOTTOM SLOT");
            print("1) PARKING TO UP SLOT");
            print("2) PARKING TO RFID READ SLOT");
            print(">");
            in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                ret = otb2Drv:park(tonumber(in_line));
                print("park result: " .. ret);
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "rs") then
            print("*** resume ***");
            print("Choose The Park Mode:");
            print("0) RESUME FROM BOTTOM SLOT");
            print("1) RESUME FROM UP SLOT");
            print("2) RESUME FROM RFID READ SLOT");
            print(">");
            in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                ret = otb2Drv:resume(tonumber(in_line));
                print("resume result: " .. ret);
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "fld") then
            print("*** frontal load ***");
            print("Choose The Frontal Load Mode:");
            print("0) DISABLE READ");
            print("1) ENABLE UP READ");
            print("2) ENABLE BOTTOM READ");
            print("3) ENABLE RFID READ");
            print("4) ENABLE LOAD WITHOUT READ");
            print(">");
            in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                ret = otb2Drv:frontalLoad(tonumber(in_line));
                print("frontal load result: " .. ret);
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "sca") then
            print("*** scan all barcodes ***");
            print("Choose The Scanner Mode:");
            print("0) Up");
            print("1) BOTTOM");
            print(">");
            in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                local bcNumbersTable = otb2Drv:scanAllRoiBC(tonumber(in_line));
                if(bcNumbersTable ~= nil) then
                    print("bcNumbersTable:");
                    for key,value in pairs(bcNumbersTable) do --actualcode
                        print("--> ","Roi-" .. key, bcNumbersTable[key]);
                    end
                else
                    print("error during sca op.");
                end
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "scx") then
            print("*** scan all barcodes ***");
            print("Choose The Scanner Mode:");
            print("0) Up");
            print("1) BOTTOM");
            print(">");
            local scanType = tonumber(pop_lua_input());
            print("Insert the ROI id:");
            print(">");
            local roiId = tonumber(pop_lua_input());
            print("Insert the id of the BC to be read (255 means all BC):");
            print(">");
            local bcIdx = tonumber(pop_lua_input());

            if ((scanType ~= nil) and (roiId ~= nil) and (bcIdx ~= nil)) then
                local bcDataTable = otb2Drv:scanRoiXBCDt(scanType,roiId,bcIdx);
                if(bcDataTable ~= nil) then
                    print("bcNumberTables:");
                    for key,value in pairs(bcDataTable) do --actualcode
                        print("--> ","BC_DATA-" .. key, bcDataTable[key]);
                    end
                else
                    print("error during scx op.");
                end
            else
                print("invalid option");
            end;
        -------------------------------------------------------
        elseif (in_line == "pss") then
            local entrance_date = "";
            local entrance_hour = "";
            local barcode_data = "";

            print("*** print single stay ***");
            print("Input entrance date (es. dd/mm/aaaa):");
            entrance_date = pop_lua_input();
            print("Input entrance date (es. hh:mm:ss):");
            entrance_hour = pop_lua_input();
            print("Input bar-code data:");
            barcode_data = pop_lua_input();
                        
            ret = otb2Drv:print_singleStay(barcode_data, entrance_date, entrance_hour,0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pjd") then
            print("*** print JPSDemo ticket ***");                        
            ret = otb2Drv:printTckt("JPSDemo_01_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pje") then
            print("*** print JPSEntry ticket ***");                        
            ret = otb2Drv:printTckt("JPSEntry_02_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pjp") then
            print("*** print JPSPay ticket ***");                        
            ret = otb2Drv:printTckt("JPSPay_03_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pjx") then
            print("*** print JPSExit ticket ***");                        
            ret = otb2Drv:printTckt("JPSExit_04_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pcs") then
            print("*** print JPSCashSnapshot ticket ***");                        
            ret = otb2Drv:printTckt("JPSCashSnapshot_05_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pjr") then
            print("*** print JPSReceipt ticket ***");                        
            ret = otb2Drv:printTckt("JPSReceipt_06_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "ppr") then
            print("*** print JPSPosReceipt ticket ***");                        
            ret = otb2Drv:printTckt("JPSPosReceipt_07_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pim") then
            print("*** print JPSImage ticket ***");                        
            ret = otb2Drv:printTckt("JPSImage_08_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pjc") then
            print("*** print JPSCrdNote ticket ***");
            ret = otb2Drv:printTckt("JPSCrdNote_09_00",0,0);
            print("print result: " .. ret);
            -------------------------------------------------------
        elseif (in_line == "pjl") then
            print("*** print JPSLost ticket ***");
            ret = otb2Drv:printTckt("JPSLost_10_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pjs") then
            print("*** print JPSSubscr ticket ***");
            ret = otb2Drv:printTckt("JPSSubscr_11_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pnt") then
            local n = 0;
            ret = 0;
            print("*** print n JPSDemo ticket ***");
            print("Input the number of jpj ticket to print");
            n = tonumber(pop_lua_input());
            while((n > 0) and ret >= 0) do
                print("Remaining tickets to print: " .. n);
                if(ret >= 0) then
                    ret = otb2Drv:feed();
                    print("feed result: " .. ret);
                end
                if(ret >= 0) then
                    ret = otb2Drv:printTckt("JPSDemo_01_00",0,0);
                    print("print result: " .. ret);
                end
                if(ret >= 0) then
                    ret = otb2Drv:eject(1);
                    print("eject result: " .. ret);
                end
                n = n -1;
            end
        -------------------------------------------------------
        elseif (in_line == "fer") then
            local n = 0;
            ret = 0;
            print("*** feed, emit retire cycle  ***");
            print("->*** feed ***");
            ret = otb2Drv:feed();
            print("feed result: " .. ret);
            _scheduler.sleep_ms(500);
            
            print("->*** print JPSDemo ticket ***");                        
            ret = otb2Drv:printTckt("JPSDemo_01_00",0,0);
            print("print result: " .. ret);
            _scheduler.sleep_ms(500);
            
            print("->*** eject ticket ***");                        
            ret = otb2Drv:eject(0);
            print("eject result: " .. ret);
            _scheduler.sleep_ms(500);
            
            print("->*** frontal load ticket ***");                        
            ret = otb2Drv:frontalLoad(4);
            print("frontal load result: " .. ret);
            _scheduler.sleep_ms(500);

            print("->*** eject ticket ***");                        
            ret = otb2Drv:eject(3);
            print("eject result: " .. ret);
            
        -------------------------------------------------------
        elseif (in_line == "cd") then
            print("*** custom data access ***");
            print("Choose The Access Mode:");
            print("0) Read");
            print("1) Write");
            print("2) Reset");
            print(">");

            local accessMode = tonumber(pop_lua_input());

            if(accessMode == 0) then
                ret = otb2Drv:readCstmData();
            elseif (accessMode == 1) then
                print("Input Custom Data:");
                print(">");
                local customData = pop_lua_input();
                ret = otb2Drv:writeCstmData(customData);
            elseif (accessMode == 2) then
                ret = otb2Drv:resetCstmData();                
            else
                print("Invalid Option.");
            end

            print("custom data access result: " .. ret);
      -------------------------------------------------------
        elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
            repeat
                msg = _scheduler.pend();
                print("otb2DrvTC-> msg=", msg);
            until(msg == "otb2drv");
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
end-- function otb2DrvMainApp()