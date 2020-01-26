 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - PrinterDriver Test Case               ");
    print("--------------------------------------------------");
    print("PrinterDriverLuaIF Menu:");
    print("To display menu press '?'.");
    print("");
    print("*** Commands ***");
    print("- 'cr'   - To create the Printer instance");
    print("- 'it'   - Init to initialize Printer ");
    print("- 'st'   - Get printer status");
    print("- 'ds'   - Dispose the printer");
    print("- 'pr'   - Print a text");
    print("- 'pbc'  - Print a bar code");
    print("- 'sbr'  - Set a block rotation");
    print("- 'sp'   - Set nex position to print");
    print("- 'ct'   - Execute a paper cut");
    print("- 'ep'   - Execute an end of page cmd");
    print("- 'pjd'  - To print a JPSDemo ticket");
    print("- 'pje'  - Print JPSEntry ticket");
    print("- 'pjp'    - To print a JPSPay ticket");
    print("- 'pjx'    - To print a JPSExit ticket");
    print("- 'pjr'    - To print a JPSReceipt ticket");
    print("- 'ppr'    - To print a JPSPosReceipt ticket");
    print("- 'pcs'    - To print a JPSCashSnapshot ticket");
    print("- 'pim'    - To print a JPSImage ticket");
    print("- 'pjc'    - To print a JPSCreditNote ticket");
    print("- 'pjl'    - To print a JPSLost ticket");
    print("- 'pjs'    - To print a JPSSubscr ticket");
    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function printerDriverTC()

    local msg;

    repeat
        msg = _scheduler.pend();
        print("printerDriverTC-> msg=", msg);
    until(msg == "printdrv");
    printMenu();

    local printerDrv = PrinterDriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
        -------------------------------------------------------
        if (in_line == "?") then
            printMenu();
        -------------------------------------------------------
        elseif (in_line == "cr") then
            print("*** create ***");
            ret = printerDrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json", "./Resources/AdditionalData.json");
        -------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
            ret = printerDrv:init();
            print("init result: " .. ret);
        -------------------------------------------------------
         elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = printerDrv:status();
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
        elseif (in_line == "pr") then
            print("*** print ***");
            print("Input how many line to be printed: ");
            
            in_line = pop_lua_input();
                        
            if (tonumber(in_line) ~= nil) then
                local tot_ln = tonumber(in_line)
                in_line = "";
                for i=1, tot_ln, 1 do
                    print("Input the line no. " .. i .." to be printed: ");
                    print(">");
                    in_line = in_line .. pop_lua_input();
                    in_line = in_line .. "\n";
                end

                io.write("Printing [");
                io.write(in_line);
                io.write("]");

                ret = printerDrv:print(in_line,string.len(in_line),0);
                print("print result: " .. ret);

            else
                print("invalid lines number");
            end;
        -------------------------------------------------------
        elseif (in_line == "pbc") then
            print("*** print bar code ***");
            print("Input the bar code type to be printed: ");
            print("(0=UPCA, 1=UPCE, 2=EAN13, 3=EAN8, 4=Code39, 5=ITF, 6=Codabar, 7=Code128, 8=PDF417, 9=DATAMATRIX, 10=QRCODE)");
            in_line = pop_lua_input();
                        
            if (tonumber(in_line) ~= nil) then
                local bc_type= tonumber(in_line)
                print("Input the line to be printed: ");
                print(">");
                in_line = pop_lua_input();
                
                io.write("Printing [");
                io.write(in_line);
                io.write("] as Bar Code");
                ret = printerDrv:printBrCd(bc_type, in_line, string.len(in_line));
                print("printBrCd result: " .. ret);

            else
                print("invalid bar code type");
            end;
        -------------------------------------------------------
        elseif (in_line == "sbr") then
            print("*** set block rotation ***");
            local rot_type = 0;
            local force_end = 0;
            print("Do you want to stop previuos rotation setting?");
            print("(0=NO, 1=YES)");
            in_line = pop_lua_input();
                        
            if (tonumber(in_line) ~= nil) then
                force_end = tonumber(in_line);
                
                if(force_end == 0) then
                    print("Input the rotation type to set: ");
                    print("(0=DISABLED, 1=ROTATE_0, 2=ROTATE_90, 3=ROTATE_180, 4=ROTATE_270)");
                    in_line = pop_lua_input();
                    if (tonumber(in_line) ~= nil) then
                        rot_type = tonumber(in_line);
                        ret = printerDrv:setBlkRot(force_end, in_line);
                        print("setBlkRot result: " .. ret);
                    else
                        print("invalid rotation type type");
                    end;
                else
                    ret = printerDrv:setBlkRot(force_end, in_line);
                    print("setBlkRot result: " .. ret);                 
                end;
            else
                print("invalid bar code type");
            end;
        -------------------------------------------------------
        elseif (in_line == "sp") then
            print("*** set position ***");
            local x = 0;
            local y = 0;
            print("Insert the x coordinate in tenth of mm?");
            in_line = pop_lua_input();
                        
            if (tonumber(in_line) ~= nil) then
                x = tonumber(in_line);
                
                print("Insert the y coordinate in tenth of mm?");
                in_line = pop_lua_input();
                if (tonumber(in_line) ~= nil) then
                    y = tonumber(in_line);
                    ret = printerDrv:setPstn(x, y);
                    print("setPstn result: " .. ret);
                else
                    print("invalid y coordinate");
                end;
            else
                print("invalid x coordinate");
            end;
        -------------------------------------------------------
        elseif (in_line == "ds") then
            print("*** dispose ***");
            ret = printerDrv:dispose();
            print("dispose result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "ct") then
            print("*** exec cut ***");
            ret = printerDrv:cut();
            print("cut result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "ep") then
            print("*** exec end of page ***");
            print("Do you wat to finally cut the paper?");
            print("(0=NO, 1=YES)");
            in_line = pop_lua_input();
            if (tonumber(in_line) ~= nil) then
                local cut = tonumber(in_line);
                ret = printerDrv:endOfPage(cut);
                print("endOfPage result: " .. ret);
            else
                print("invalid cut option");
            end;
        -------------------------------------------------------
        elseif (in_line == "pjd") then
            print("*** print JPSDemo ticket ***");                        
            ret = printerDrv:printTckt("JPSDemo_01_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pje") then
            print("*** print JPSEntry ticket ***");
            ret = printerDrv:printTckt("JPSEntry_02_00");
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pjp") then
            print("*** print JPSPay ticket ***");                        
            ret = printerDrv:printTckt("JPSPay_03_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pjx") then
            print("*** print JPSExit ticket ***");                        
            ret = printerDrv:printTckt("JPSExit_04_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pcs") then
            print("*** print JPSCashSnapshot ticket ***");                        
            ret = printerDrv:printTckt("JPSCashSnapshot_05_00");
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pjr") then
            print("*** print JPSReceipt ticket ***");                        
            ret = printerDrv:printTckt("JPSReceipt_06_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "ppr") then
            print("*** print JPSPosReceipt ticket ***");                        
            ret = printerDrv:printTckt("JPSPosReceipt_07_00");
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pim") then
            print("*** print JPSImage ticket ***");                        
            ret = printerDrv:printTckt("JPSImage_08_00",0,0);
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pjc") then
            print("*** print JPSCrdNote ticket ***");
            ret = printerDrv:printTckt("JPSCrdNote_09_00");
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pjl") then
            print("*** print JPSLost ticket ***");
            ret = printerDrv:printTckt("JPSLost_10_00");
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pjs") then
            print("*** print JPSSubscr ticket ***");
            ret = printerDrv:printTckt("JPSSubscr_11_00");
            print("print result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
            repeat
                msg = _scheduler.pend();
                print("printerDriverTC-> msg=", msg);
            until(msg == "printdrv");
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
end-- function printerDriverPainApp()