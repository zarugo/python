 -------------------------------- SCEDULER ------------------------------
 local _scheduler = require "cosched.scheduler_v2";
 ------------------------------------------------------------------------
 
 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - DisplayDriver Test Case               ");
    print("--------------------------------------------------");
    print("DisplayDriverLuaIF Menu:");
	print("To display menu press '?'.");
	print("");
	print("*** Commands ***");
    print("- 'cr'     - To create the Display Intsance");
    print("- 'it'     - To initialize the Display");
    print("- 'st'     - To get the Display status");
    print("- 'ds'     - To dispose the display");
    print("- 'ss'     - To set a screen into the display");
	print("- 'sa'     - To iteratively set all screen");
    print("- 'sb'     - To set a button into the display");
    print("- 'bx'     - To set a button extended into the display");
    print("- 'pv'     - To show/hide the payment view");
    print("- 'uc'     - To update currency view");
    print("- 'kp'     - To show/hide the keypad");
    print("- 'sl'     - Set current language");
    print("- 'sd'     - To show/hide the selection dialog");

    print("- 'rt'     - To return to main menu.");
    print("");
    io.write(">");
end

-- Main Application Corutine:
function displayDriverTC()

    local msg;

    repeat
        msg = _scheduler.pend();
        print("displayDrvTC-> msg=", msg);
    until(msg == "displaydrv");
    printMenu();

    local displayDrv = DisplayDriverLuaIF:new();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "cr") then
            print("*** create ***");
            ret = displayDrv:create("./Resources/www/webcfgtool/jpsdemoluatc/ConfigData.json");
            print("create result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "it") then
            print("*** init ***");
            ret = displayDrv:init();
            print("init result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "st") then
            print("*** status ***");
            local statusTable = displayDrv:status();
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
            ret = displayDrv:dispose();
            print("dispose result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "ss") then
            print("*** set screen ***");
			print("Input the 'Display ID':");
            print(">");
            local dispId = tonumber(pop_lua_input());
			print("Input the 'Par0:");
            print(">");
            local par0 = pop_lua_input();
			if(par0 == nil) then par0="" end;
			print("Input the 'Par1:");
            print(">");
            local par1 = pop_lua_input();
			if(par1 == nil) then par1="" end;
			print("Input the 'Par2:");
            print(">");
            local par2 = pop_lua_input();
			if(par2 == nil) then par2="" end;
			print("Input the 'Par3:");
            print(">");
            local par3 = pop_lua_input();
			if(par3 == nil) then par3="" end;
			print("Input the 'Par4:");
            print(">");
            local par4 = pop_lua_input();
			if(par4 == nil) then par4="" end;
			
			ret = displayDrv:setscreen(dispId,par0,par1,par2,par3,par4);
			print("set screen result: " .. ret);
        -------------------------------------------------------			
        elseif (in_line == "sa") then
            print("*** set all screen ***");
			local i=0;
			print("Input q to quit the test any other key to go on:");
			local input = pop_lua_input();
			while (input~="q" and i<=501) do
			    -- Excludes non configured screen id:
				if((i>=34  and i<=49)   or (i>=53  and i<= 99)  or 
				   (i>=53  and i<= 99)  or (i>=113 and i<= 120) or
				   (i>=126 and i<= 130) or (i>=138 and i<= 140) or
				   (i>=146 and i<= 150) or (i>=157 and i<= 200) or
				   (i>=209 and i<= 500)) then
			    -- Manages configured screen id:
				else
					if(i==3) then ret = displayDrv:setscreen(i,"","","","","");
					elseif(i==9) then ret = displayDrv:setscreen(i,"12345","10/11/2012","","","");
					elseif(i==10) then ret = displayDrv:setscreen(i,"54321","12/11/2010","100,37","","");
					elseif((i>=26) and (i<=32)) then ret = displayDrv:setscreen(i,"55,7","","","","");
					elseif(i==33) then ret = displayDrv:setscreen(i,"ABCDE","","","","");
					elseif(i==50) then ret = displayDrv:setscreen(i,"0","00","/P","1.1.1","");
					elseif(i==51) then ret = displayDrv:setscreen(i,"ABCDE","","","","");
					elseif((i==52) or (i>=100 and i<=108) or (i==112))then ret = displayDrv:setscreen(i,"ABCDE","","","","");
					elseif(i==109 or i==111 or i==122 or i==125) then ret = displayDrv:setscreen(i,"ABCDE","10/11/2012","45,67","","");
					elseif(i==110) then ret = displayDrv:setscreen(i,"ABCDE","10/11/2012","","","");
					elseif(i==131) then ret = displayDrv:setscreen(i,"0","it","MainText","SubText","6");
					elseif(i==132 or i==133) then ret = displayDrv:setscreen(i,"15,78","","","","");
					elseif(i==141) then ret = displayDrv:setscreen(i,"","10/11/2012","","","");
					elseif(i==142) then ret = displayDrv:setscreen(i,"","10/11/2012","7","","");
					elseif(i==203) then ret = displayDrv:setscreen(i,"123","456","","","");
					elseif(i==205) then ret = displayDrv:setscreen(i,"15","","","","");
					else ret = displayDrv:setscreen(i,"","","","","");
					end				
					print("set screen result: " .. ret);
					print("Input q to quit the test any other key to go on:");
					input = pop_lua_input();
				end
					i = i + 1;
			end
		
        -------------------------------------------------------
        elseif (in_line == "sb") then
            print("*** set button ***");
			print("Input the 'Button ID':");
            print("(0=Cancel, 1=Receipt, 2=Language, 3=PpRldMcPr, 4=LostTicket)");
            print(">");
            local buttId = tonumber(pop_lua_input());
			print("Input the 'Button Status:");
			print("(0=Off, 1=On, 2=Blink)");
            print(">");
            local buttSt = tonumber(pop_lua_input());
			print("Input the 'Button Flag Mode:");
			print("(0=NotFlagged, 1=Flagged)");
            print(">");
            local buttFlg = tonumber(pop_lua_input());
			
			print("Input the how many icons:");
            print(">");
            local iconsNo = tonumber(pop_lua_input());
			print("Input the 'Ico0 Id:");
			print(">");
			local ico0 = tonumber(pop_lua_input());
			if(ico0 == nil) then ico0=0 end;
			print("Input the 'Ico1 Id:");
			print(">");
			local ico1 = tonumber(pop_lua_input());
			if(ico1 == nil) then ico1=0 end;
			print("Input the 'Ico2 Id");
			print(">");
			local ico2 = tonumber(pop_lua_input());
			if(ico2 == nil) then ico2=0 end;
			print("Input the 'Ico3 Id");
			print(">");
			local ico3 = tonumber(pop_lua_input());
			if(ico3 == nil) then ico3=0 end;
			print("Input the 'Text':");
			print(">");
			local text = pop_lua_input();
			if(text == nil) then text="" end;
			print("Input the 'Optional Text':");
			print(">");
			local optText = pop_lua_input();
			if(optText == nil) then optText="" end;
			
			ret = displayDrv:setbutton(buttId,buttSt,buttFlg,iconsNo,ico0,ico1,ico2,ico3,text,optText);
			print("set button result: " .. ret);
        -------------------------------------------------------
        elseif (in_line == "bx") then
            print("*** set button extended ***");
			print("Input the 'Button ID':");
            print("(0=Cancel, 1=Receipt, 2=Language, 3=PpRldMcPr, 4=LostTicket)");
            print(">");
            local buttId = tonumber(pop_lua_input());
			print("Input the 'Button Status:");
			print("(0=Off, 1=On, 2=Blink)");
            print(">");
            local buttSt = tonumber(pop_lua_input());
			print("Input the 'Button Flag Mode:");
			print("(0=NotFlagged, 1=Flagged)");
            print(">");
            local buttFlg = tonumber(pop_lua_input());			
			print("Input the 'Button Text Id:");
            print(">");
            local buttTxtId = tonumber(pop_lua_input());
			ret = displayDrv:setbuttonxt(buttId,buttSt,buttFlg,buttTxtId);
			print("set buttonxt result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "pv") then
            print("*** show/hide payment view ***");
			print("Input the show/hide flag:");
            print("(0=Disable, 1=Enable)");
            print(">");
            local enabDisab = tonumber(pop_lua_input());			
			ret = displayDrv:shwhidpv(enabDisab);
			print("show/hide payment result: " .. ret);	
		-------------------------------------------------------
        elseif (in_line == "uc") then
            print("*** To update currency view ***");
			ret = displayDrv:updpaycur(enabDisab);
			print("update currency view result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "kp") then
            print("*** show/hide keypad ***");
			print("Input the show/hide flag:");
            print("(0=Disable, 1=Enable)");
            print(">");
            local enabDisab = tonumber(pop_lua_input());			
			print("Input the masked/clear input flag:");
            print("(0=Clear, 1=Masked)");
            print(">");
            local mskdClr = tonumber(pop_lua_input());
			print("Input the maximum input length:");
            print(">");
            local inlength = tonumber(pop_lua_input());			
			ret = displayDrv:shwhidkp(enabDisab,mskdClr,inlength);
			print("show/hide key pad result: " .. ret);	
		-------------------------------------------------------
        elseif (in_line == "sl") then
            print("*** set current language ***");
			print("Input the language (e.g. 'en' or 'it'):");
            print(">");
            local lang = pop_lua_input();
			if(lang == nil) then lang="" end;
			ret = displayDrv:setcurrlang(lang);
			print("set current language result: " .. ret);
		-------------------------------------------------------
        elseif (in_line == "sd") then
            print("*** show/hide selection dialog ***");
			print("Input the show/hide flag:");
            print("(0=Disable, 1=Enable)");
            print(">");
            local enabDisab = tonumber(pop_lua_input());			
			print("Input the autoclose input flag:");
            print("(0=No Autoclose, 1=Autoclose)");
            print(">");
            local autocls = tonumber(pop_lua_input());
			print("Input the maximum view mode (0=Grid, 1=List, 2=UsrGrid, 3=UsrList):");
            print(">");
            local vwmd = tonumber(pop_lua_input());			
			ret = displayDrv:shwhidsd(enabDisab,autocls,vwmd);
			print("show/hide selection dialog result: " .. ret);	
		-------------------------------------------------------
		elseif (in_line == "rt") then
            print("*** return ***");
            _scheduler.publish("return");
			repeat
                msg = _scheduler.pend();
                print("displayDrvTC-> msg=", msg);
            until(msg == "displaydrv");
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
end-- function displayDrvMainApp()