 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - PaymentService Test Case               ");
    print("--------------------------------------------------");
    print("PaymentServiceLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'   - To create the Payment instance");
    print("- 'it'   - Init to initialize Payment ");
    print("- 'st'   - Get payment status");
    print("- 'ds'   - Dispose the payment");
	print("- 'pst'  - To start a payment");
	print("- 'psp'  - To stop a payment");
	print("- 'gvc'  - Give the change");
	print("- 'cpa'  - Change payment amount");
    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function paymentServiceTC()

    local msg;
	local siteCode;
	local start_ts, end_ts, family, freeTime, exitTime;

    repeat
        msg = _scheduler.pend();
        print("paymentServiceTC-> msg=", msg);
    until(msg == "paymentsrv");
    printMenu();

    local paymentSrv = PaymentServiceLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = paymentSrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
			ret = paymentSrv:init();
			print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "ds") then
            print("*** dispose ***");
            ret = paymentSrv:dispose();
            print("dispose result: " .. ret);
		-------------------------------------------------------
         elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = paymentSrv:status();
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
        elseif (in_line == "pst") then
            print("*** payment start ***");            
			local amaunt=0;
			local mode=-1;
			local algo=-1;
			local max_change=-1;
			local pcs_limit=-1;		           
			local cngonabrt=-1;
			local resTable;

            print("Input the amount to be payed:");
            print(">");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
                amaunt = tonumber(in_line);

				print("Input payment mode (-1 ->Default (Cfg), 0 ->Cash, 1 ->Pos, 2 ->CashPos):");
				print(">");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					mode = tonumber(in_line);
				else
					print("invalid payment mode input, using default");
				end;	
					
				print("Input change algo (-1 ->Default (Cfg), 0 ->MinPcs, 1 ->BalPcs):");
				print(">");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					algo = tonumber(in_line);
				else
					print("invalid payment algo input, using default");
				end;	
				
	            print("Input the maximum change amount (-2 ->Unlimited, -1 ->Default (Cfg)):");
				print(">");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					max_change = tonumber(in_line);								
				else
					print("invalid maximum change input, using default");
				end;

				print("Input the cumulative pieces limit (-2 ->Unlimited, -1 ->Default (Cfg)):");
				print(">");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					pcs_limit = tonumber(in_line);						
				else
					print("invalid cumulative pieces limit input, using default");
				end;
				
				print("Input the cngonabrt flag (-1 ->Default (Cfg), 0 -> disabled, 1 -> enabled):");
				print(">");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					cngonabrt = tonumber(in_line);						
				else
					print("invalid cngonabrt input, using default");
				end;
				
				resTable = paymentSrv:strtpymt(amaunt, mode, algo, max_change, pcs_limit, cngonabrt);
				if(resTable ~= nil) then
					print("errCode " , "'" .. resTable["errCode"]  .. "'");
					print("user_ref ", "'" .. resTable["user_ref"] .. "'");
				else
					print("invalid payment mode input, using default");
				end;
            else
                print("invalid amaunt input");
            end;	      
		-------------------------------------------------------
        elseif (in_line == "cpa") then
            print("*** change payment amount ***");
			local amaunt=0;
			local resTable;
            print("Input the amount to be payed:");
            print(">");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
				amaunt = tonumber(in_line);			
				resTable = paymentSrv:cngamt(amaunt);
				if(resTable ~= nil) then
					print("errCode " , "'" .. resTable["errCode"]  .. "'");
					print("user_ref ", "'" .. resTable["user_ref"] .. "'");
				end
			else
				print("error on op execution");
			end;		
		-------------------------------------------------------
        elseif (in_line == "psp") then
            print("*** payment stop ***");
			local algo=-1;
			local max_change=-1;
			local pcs_limit=-1;		           
			local cngonabrt=-1;
			local resTable;

			print("Input change algo (-1 ->Default (Cfg), 0 ->MinPcs, 1 ->BalPcs):");
			print(">");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
				algo = tonumber(in_line);
			else
				print("invalid payment algo input, using default");
			end;	
			
			print("Input the maximum change amount (-2 ->Unlimited, -1 ->Default (Cfg)):");
			print(">");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
				max_change = tonumber(in_line);								
			else
				print("invalid maximum change input, using default");
			end;

			print("Input the cumulative pieces limit (-2 ->Unlimited, -1 ->Default (Cfg)):");
			print(">");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
				pcs_limit = tonumber(in_line);						
			else
				print("invalid cumulative pieces limit input, using default");
			end;
			
			print("Input the cngonabrt flag (-1 ->Default (Cfg), 0 -> disabled, 1 -> enabled):");
			print(">");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
				cngonabrt = tonumber(in_line);						
			else
				print("invalid cngonabrt input, using default");
			end;
			
			resTable = paymentSrv:stppymt(algo, max_change, pcs_limit, cngonabrt);
			if(resTable ~= nil) then
				print("errCode " , "'" .. resTable["errCode"]  .. "'");
				print("user_ref ", "'" .. resTable["user_ref"] .. "'");
			else
				print("error on op execution");
			end;   
		-------------------------------------------------------
        elseif (in_line == "gvc") then
            print("*** give change ***");
			local change=0;
			local algo=-1;
			local max_change=-1;
			local pcs_limit=-1;		           
			local resTable;

            print("Input the change to supply:");
            print(">");
			in_line = pop_lua_input();
			if (tonumber(in_line) ~= nil) then
                change = tonumber(in_line);
					
				print("Input change algo (-1 ->Default (Cfg), 0 ->MinPcs, 1 ->BalPcs):");
				print(">");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					algo = tonumber(in_line);
				else
					print("invalid payment algo input, using default");
				end;	
				
	            print("Input the maximum change amount (-2 ->Unlimited, -1 ->Default (Cfg)):");
				print(">");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					max_change = tonumber(in_line);								
				else
					print("invalid maximum change input, using default");
				end;

				print("Input the cumulative pieces limit (-2 ->Unlimited, -1 ->Default (Cfg)):");
				print(">");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					pcs_limit = tonumber(in_line);						
				else
					print("invalid cumulative pieces limit input, using default");
				end;
							
				resTable = paymentSrv:gvcng(change, algo, max_change, pcs_limit);
				if(resTable ~= nil) then
					print("errCode " , "'" .. resTable["errCode"]  .. "'");
					print("user_ref ", "'" .. resTable["user_ref"] .. "'");
				else
					print("error on op execution");
				end;
            else
                print("invalid amaunt input");
            end;	       
		-------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("paymentServiceTC-> msg=", msg);
            until(msg == "paymentsrv");
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
end-- function paymentServicePainApp()