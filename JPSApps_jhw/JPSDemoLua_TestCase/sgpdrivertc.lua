 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
bnkntsQty={0};
coinsQty={0};

 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - SGPDriver Test Case               ");
    print("--------------------------------------------------");
    print("SGPDriverLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'     - To create the SGP Intsance");
    print("- 'it'     - To initialize the SGP");
    print("- 'st'     - To get the SGP status");
    print("- 'ds'     - To dispose the SGP");
    print("- 'jsr'    - To retrieve a json report");
    print("- 'pst'    - To start a payment");
	print("- 'psp'    - To stop a payment");
	print("- 'gvc'    - Give the change");
	print("- 'cpa'    - Change payment amount");
	print("- 'ecf'    - Execute control function");
	print("- 'sdq'    - Set denomination quantity");
    print("- 'rt'     - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function sgpDriverTC()

    local msg;

    repeat
        msg = _scheduler.pend();
        print("sgpDrvTC-> msg=", msg);
    until(msg == "sgpdrv");
    printMenu();

    local sgpDrv = SGPDriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = sgpDrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
            print("create result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
			ret = sgpDrv:init();
			print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = sgpDrv:status();
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
        elseif (in_line == "jsr") then
            print("*** jsreport ***");
            local reportTable = sgpDrv:jsreport();
            print("");
            print("--------------------------------------------------");
            if(reportTable ~= nil) then
				print("\"jsreport\":" .. reportTable["jsreport"]);
				print("");
            end
        -------------------------------------------------------
        elseif (in_line == "ds") then
            print("*** dispose ***");
            ret = sgpDrv:dispose();
            print("dispose result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "pst") then
            print("*** payment start ***");            
			local amaunt=0;
			local max_change=0;
			local encoins_msk="";
			local enbnknts_msk="";
			local ovrdcoins_msks="";
			
            print("Input the amount to be payed:");
            print(">");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
                amaunt = tonumber(in_line);
	            print("Input the maximum change:");
				print(">");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					max_change = tonumber(in_line);					
					print("Input the enab. coins mask change (eg. 000000FF):");
					print(">");
					encoins_msk = pop_lua_input();
					print("Input the enab. banknotes mask change (eg. 000000FF):");
					print(">");
					enbnknts_msk = pop_lua_input();
					print("Input the enab. override coins mask change (eg. 000000FF):");
					print(">");
					ovrdcoins_msks = pop_lua_input();					
					ret = sgpDrv:pymtstart(amaunt, max_change, encoins_msk, enbnknts_msk, ovrdcoins_msks);
					print("payment start result: " .. ret);
				else
					print("invalid maximum change input");
				end;				
            else
                print("invalid amaunt input");
            end;	
      -------------------------------------------------------
        elseif (in_line == "psp") then
            print("*** payment stop ***");            
			local refund_money=0;
			
			print("Choose The Stop Mode:");
            print("0) Encash Money");
            print("1) Refund Money");
            print(">");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
				refund_money = tonumber(in_line);			
				ret = sgpDrv:pymtstop(refund_money);
				print("payment stop result: " .. ret);
			else
				print("invalid refund_money input");
			end;				
      -------------------------------------------------------
        elseif (in_line == "gvc") then
            print("*** give change ***");
			billsQty={0};
			coinsQty={0};
			local i=1;
			
			while(i<5) do
				print("Enter the quantity for bills cassette-" .. tostring(i) .. ":");
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
			
			i=1;
			while(i<8) do
				print("Enter the quantity for coins hopper-" .. tostring(i) .. ":");
				print(">");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					coinsQty[i] = tonumber(in_line);
					print("input-" .. tostring(i) .. "=" .. tostring(coinsQty[i]));
					i=i+1;
				else
					print("invalid input");
				end;	
            end
			
			ret = sgpDrv:gvcng(billsQty,coinsQty);
			print("give change result: " .. ret);
					
      -------------------------------------------------------
        elseif (in_line == "cpa") then
            print("*** change payment amount ***");
			local amount=0;
            print("Input the amount to be payed:");
            print(">");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
				amount = tonumber(in_line);			
				ret = sgpDrv:cngpymtamnt(amount);
				print("change payment amount result: " .. ret);
			else
				print("invalid amount input");
			end;
      -------------------------------------------------------
        elseif (in_line == "ecf") then
            print("*** execute control function ***");
			local ctrlfunc="";
			local wait=0;
            print("Input the function name: ");
            print("(ex. 'OpenShutter','CloseShutter','CngBoxLampOn','CngBoxLampOff','AntiJam')");
            print(">");
			ctrlfunc = pop_lua_input();

			print("Choose The Execution Mode:");
            print("0) Don't wait for completion");
            print("1) Wait for completion");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
				wait = tonumber(in_line);			
				ret = sgpDrv:excctrlfnc(ctrlfunc, wait);
				print("execute control function result: " .. ret);
			else
				print("invalid execution mode input");
			end;
      -------------------------------------------------------
        elseif (in_line == "sdq") then
            print("*** set denomination quantity ***");
			local tbname="";
			local idx=0;
			local qtty=0;
			
            print("Input the tab name: ");
            print("(ex. 'coins','bills')");
            print(">");
			tbname = pop_lua_input();

			print("Insert the denomination index:");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
				idx = tonumber(in_line);
				print("Insert the quantity:");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					qtty = tonumber(in_line);			
					ret = sgpDrv:setdenqty(tbname, idx, qtty);
					print("set denomination quantity result: " .. ret);
				else
					print("invalid quantity input");
				end;
			else
				print("invalid denomination index input");
			end;
      -------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("sgpDrvTC-> msg=", msg);
            until(msg == "sgpdrv");
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
end-- function sgpDrvMainApp()