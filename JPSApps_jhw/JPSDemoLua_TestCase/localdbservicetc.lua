 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - LocalDBService Test Case               ");
    print("--------------------------------------------------");
    print("LocalDBServiceLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'   - To create the LocalDB instance");
    print("- 'it'   - Init to initialize LocalDB ");
    print("- 'st'   - Get localdb status");
    print("- 'ds'   - Dispose the localdb");
	print("- 'oop'  - Execute operator operations");
	print("- 'oup'  - Execute user pass operations");
    print("- 'rt'   - To return to main menu.");
    print("");
    io.write(">");
end

opts = {"CrtTB",
        "DltTB",
		"Add",
		"AddAll",
		"RdAll",
		"RdByIdx",
		"RdByKey",
		"UpdtByIdx",
		"UpdtByKey",
		"UpdtAllByKey",
		"DltAll",
		"DltByIdx",
		"DltByKey"};

 -- Prints available operations to the console:
local function printOps()
    print("");
    print("Input the operation type param: ");
	print("1 = CrtTB,       2 = DltTB,       3 = Add,           4 = AddAll,    5  = RdAll,    6  = RdByIdx,  7 = RdByKey,");
	print("8 = UpdtByIdx,   9 = UpdtByKey,  10 = UpdtAllByKey, 11 = DltAll,    12 = DltByIdx, 13 = DltByKey  rt = Return");
    io.write(">");
end

 -- Operators Management:
local function oopMngmt(localdbSrv)
	local in_line, op = 1, idx, name, pwd, ret;
	local listTable;
    print("*** user operations  ***");	
	while(in_line ~= "rt") do
		listTable = nil;
		ret = nil;
		printOps();
		in_line = pop_lua_input();
		if (tonumber(in_line) ~= nil) then
			op = tonumber(in_line)
			if((opts[op] == "CrtTB") or (opts[op] == "DltTB") or (opts[op] == "Add") or (opts[op] == "AddAll") or (opts[op] == "RdAll") or (opts[op] == "DltAll")) then
				ret = localdbSrv:optorOp(op);
			elseif((opts[op] == "RdByIdx") or (opts[op] == "UpdtByIdx") or (opts[op] == "DltByIdx")) then
				print("Input the index param: ");
				in_line = pop_lua_input();
				if (tonumber(in_line) ~= nil) then
					idx = tonumber(in_line);
					ret = localdbSrv:optorOp(op, idx);
				else
					print("invalid op type");
				end
			elseif((opts[op] == "RdByKey") or (opts[op] == "UpdtByKey") or (opts[op] == "UpdtAllByKey") or (opts[op] == "DltByKey")) then
				print("Input the name param: ");
				name = pop_lua_input();
				print("Input the pwd param: ");
				pwd = pop_lua_input();
				ret = localdbSrv:optorOp(op, name, pwd);
			else
				print("invalid op type");
			end
			
			if(ret ~= nil) then
				listTable = ret["operatorsList"];
				if(listTable ~= nil) then
					print("listTable:");
					for key,value in pairs(listTable) do --actualcode
						print("--> ",key, listTable[key]);
					end
				end
			end
		else
			if(in_line ~= "rt") then print("invalid op type"); end
		end;
	end
end

 -- UserPass Management:
local function oupMngmt(localdbSrv)
	local in_line, op = 1, idx, ret, uid;
	local listTable;
    print("*** user operations  ***");	
	while(in_line ~= "rt") do
		listTable = nil;
		ret = nil;
		printOps();
		in_line = pop_lua_input();
		if (tonumber(in_line) ~= nil) then
			op = tonumber(in_line)
			if((opts[op] == "CrtTB") or (opts[op] == "DltTB") or (opts[op] == "Add") or (opts[op] == "AddAll") or (opts[op] == "RdAll") or (opts[op] == "DltAll")) then
				ret = localdbSrv:upassOp(op);
			elseif((opts[op] == "RdByIdx") or (opts[op] == "UpdtByIdx") or (opts[op] == "DltByIdx")     or 
			       (opts[op] == "RdByKey") or (opts[op] == "UpdtByKey") or (opts[op] == "UpdtAllByKey") or
				   (opts[op] == "DltByKey")) then
				print("Input the uid param: ");
				uid = pop_lua_input();
				ret = localdbSrv:upassOp(op, uid);
			else
				print("invalid op type");
			end
			
			if(ret ~= nil) then
				listTable = ret["usrpassesList"];
				if(listTable ~= nil) then
					print("listTable:");
					for key,value in pairs(listTable) do --actualcode
						print("--> ",key, listTable[key]);
					end
				end
			end
		else
			if(in_line ~= "rt") then print("invalid op type"); end
		end;
	end
end

-- Main Application Corutine:
function localdbServiceTC()
    local msg, ret, in_line, siteCode, statusTable;
	local statusTable, alarmListTable, sensorListTable;
	
    repeat
        msg = _scheduler.pend();
        print("localdbServiceTC-> msg=", msg);
    until(msg == "localdbsrv");
    printMenu();

    local localdbSrv = LocalDBServiceLuaIF:new();

    while (1) do        
        in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = localdbSrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
			ret = localdbSrv:init();
			print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "ds") then
            print("*** dispose ***");
            ret = localdbSrv:dispose();
            print("dispose result: " .. ret);
		-------------------------------------------------------
         elseif (in_line == "st") then
            print("*** status ***");
            statusTable = localdbSrv:status();
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
        elseif (in_line == "oop") then
            oopMngmt(localdbSrv);
			printMenu();
		-------------------------------------------------------
		elseif (in_line == "oup") then
            oupMngmt(localdbSrv);
			printMenu();
		-------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("localdbServiceTC-> msg=", msg);
            until(msg == "localdbsrv");
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
end-- function localdbServicePainApp()