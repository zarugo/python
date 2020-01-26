 -------------------------------- SCEDULER ------------------------------
 local scheduler = require "cosched.scheduler_v2"
 ------------------------------------------------------------------------
 require "printerdrivertc"
 require "otb2drivertc"
 require "bcreaderdrivertc"
 require "bledrivertc"
 require "displaydrivertc"
 require "gpioctrldrivertc"
 require "cpgwdrivertc"
 require "httpserverservicetc"
 require "httpclientservicetc"
 require "tariffsservicetc"
 require "sgpdrivertc"
 require "paymentservicetc"
 require "localdbservicetc"
 require "proxyreaderdrivertc"
 require "proxyrdrwrtrdrivertc"
 require "outschedservicetc"
 require "usrpassservicetc"
 require "billsdispenserdrivertc"
 require "barrierdrivertc"
 require "jblservicetc"
 require "fiscalprinterdrivertc"
 require "bill2billdrivertc"

 -- Prints menu to the console:
local function printMenu()
    print("");
    print("--------------------------------------------------");
    print("FAAC s.p.a - JPSDemo Test Case                    ");
    print("--------------------------------------------------");
    print("JPSDemoTest:");
	print("");
	print("*** Commands ***");
    print("- 'a'   - to start or resume a printer driver test ");
    print("- 'b'   - to start or resume a otb2 driver test ");
	print("- 'c'   - to start or resume a bcreader driver test ");
	print("- 'd'   - to start or resume a ble driver test ");
	print("- 'e'   - to start or resume a display driver test ");
	print("- 'f'   - to start or resume a gpio ctrl driver test ");
	print("- 'g'   - to start or resume a cpgw driver test ");
	print("- 'h'   - to start or resume an http server service test ");	
	print("- 'i'   - to start or resume an http client service test ");	
	print("- 'l'   - to start or resume an tariffs service test ");	
	print("- 'm'   - to start or resume an sgp driver test ");
	print("- 'n'   - to start or resume an payment service test ");
	print("- 'o'   - to start or resume an locald service test ");
	print("- 'p'   - to start or resume an proxyreader driver test ");
	print("- 'q'   - to start or resume an proxyrdrwrtr driver test ");
	print("- 'r'   - to start or resume an outsched service test ");
	print("- 's'   - to start or resume a usrpassservice test ");
	print("- 't'   - to start or resume a bills dispenser driver test ");
	print("- 'u'   - to start or resume ethernet barrier driver test ");
	print("- 'v'   - to start or resume a jbl service test ");
	print("- 'w'   - to start or resume fiscal printer driver test ");
	print("- 'x'   - to start or resume bill2bill driver test ");
	print("--------------------------------------------------");
	print("- '?'   - to display menu press '?'");
	print("- 'Q'   - to quit");
    print("");
    io.write(">");
end

-- Main Application Coroutine:
local function jpsDemoMainApp()   

    local msg;

    print("-------------------------------------------------");
    print("                 _______   ___  _____             ");
    print("                / __/ _ | / _ |/ ___/             ");
    print("               / _// __ |/ __ / /__               ");
    print("              /_/ /_/ |_/_/ |_\\___/              ");
    print("                                                  ");
    print("-------------------------------------------------");
    printMenu();

    while (1) do        
        local in_line = pop_lua_input();
		-------------------------------------------------------
        if (in_line == "?") then
	        printMenu();
		-------------------------------------------------------
	    elseif (in_line == "a") then
            print("*** print driver ***");
            scheduler.post(printerDriverTC,"printdrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
        -------------------------------------------------------
	    elseif (in_line == "b") then
            print("*** otb2 driver ***");
            scheduler.post(otb2DriverTC,"otb2drv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
        -------------------------------------------------------
	    elseif (in_line == "c") then
            print("*** bcreader driver ***");
            scheduler.post(bcreaderDriverTC,"bcreaderdrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "d") then
            print("*** ble driver ***");
            scheduler.post(bleDriverTC,"bledrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "e") then
            print("*** display driver ***");
            scheduler.post(displayDriverTC,"displaydrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "f") then
            print("*** gpioctrl driver ***");
            scheduler.post(gpioctrlDriverTC,"gpioctrldrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "g") then
            print("*** cpgw driver ***");
            scheduler.post(cpgwDriverTC,"cpgwdrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "h") then
            print("*** http server service ***");
            scheduler.post(httpServerServiceTC,"httpserversrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "i") then
            print("*** http client service ***");
            scheduler.post(httpClientServiceTC,"httpclientsrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "l") then
            print("*** tariffs service ***");
            scheduler.post(tariffsServiceTC,"tariffssrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "m") then
            print("*** sgp driver ***");
            scheduler.post(sgpDriverTC,"sgpdrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "n") then
            print("*** payment service ***");
            scheduler.post(paymentServiceTC,"paymentsrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "o") then
            print("*** localdb service ***");
            scheduler.post(localdbServiceTC,"localdbsrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "p") then
            print("*** proxyreader driver ***");
            scheduler.post(proxyreaderDriverTC,"proxyreaderdrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "q") then
            print("*** proxyrdrwrtr driver ***");
            scheduler.post(proxyrdrwrtrDriverTC,"proxyrdrwrtrdrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "r") then
            print("*** outsched service ***");
            scheduler.post(outschedServiceTC,"outschedsrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
		-------------------------------------------------------
	    elseif (in_line == "s") then
            print("*** usrpass service ***");
            scheduler.post(usrpassServiceTC,"usrpasssrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
     -------------------------------------------------------
      elseif (in_line == "t") then
            print("*** bills dispenser driver ***");
            scheduler.post(billsdispenserDriverTC,"billsdispenserdrv");
            msg = scheduler.pend();
            print("jpsDemoMainApp-> msg=", msg);
            printMenu();
     -------------------------------------------------------
      elseif (in_line == "u") then
        print("*** ethernet barrier driver ***");
        scheduler.post(barrierDriverTC,"barrierdrv");
        msg = scheduler.pend();
        print("jpsDemoMainApp-> msg=", msg);
        printMenu();
     -----------------------------------------------------
      elseif (in_line == "v") then
        print("*** jbl service ***");
        scheduler.post(jblServiceTC,"jblsrv");
        msg = scheduler.pend();
        print("jpsDemoMainApp-> msg=", msg);
        printMenu();
    -------------------------------------------------------
      elseif (in_line == "w") then
        print("*** fiscal printer driver ***");
        scheduler.post(fiscalprinterDriverTC,"fiscalprinterdrv");
        msg = scheduler.pend();
        print("jpsDemoMainApp-> msg=", msg);
        printMenu();
          -------------------------------------------------------
      elseif (in_line == "x") then
        print("*** bill2bill driver ***");
        scheduler.post(bill2billDriverTC,"bill2billdrv");
        msg = scheduler.pend();
        print("jpsDemoMainApp-> msg=", msg);
        printMenu();
          -------------------------------------------------------
          elseif (in_line == "Q") then
            print("*** Q ***");
            scheduler.quit();
     -------------------------------------------------------
        else
            if (string.len(in_line) > 0) then
                print("invalid command");
            end
            io.write(">");
        end-- if (in_line == "?")

		scheduler.sleep_ms(250);
    end-- while (1) do
end-- function printDriverPainApp()

 -------------------------------- SCEDULER ------------------------------
 -- This is the real scheduler code:
 scheduler.spawn(jpsDemoMainApp,0,20);
 scheduler.spawn(printerDriverTC,0,20);
 scheduler.spawn(otb2DriverTC,0,20);
 scheduler.spawn(bcreaderDriverTC,0,20);
 scheduler.spawn(bleDriverTC,0,20);
 scheduler.spawn(displayDriverTC,0,20);
 scheduler.spawn(gpioctrlDriverTC,0,20);
 scheduler.spawn(cpgwDriverTC,0,20);
 scheduler.spawn(httpServerServiceTC,0,20);
 scheduler.spawn(httpClientServiceTC,0,20);
 scheduler.spawn(tariffsServiceTC,0,20);
 scheduler.spawn(sgpDriverTC,0,20);
 scheduler.spawn(paymentServiceTC,0,20);
 scheduler.spawn(localdbServiceTC,0,20);
 scheduler.spawn(proxyreaderDriverTC,0,20);
 scheduler.spawn(proxyrdrwrtrDriverTC,0,20);
 scheduler.spawn(outschedServiceTC,0,20);
 scheduler.spawn(usrpassServiceTC,0,20);
 scheduler.spawn(billsdispenserDriverTC,0,20);
 scheduler.spawn(barrierDriverTC,0,20);
 scheduler.spawn(jblServiceTC,0,20);
 scheduler.spawn(fiscalprinterDriverTC,0,20);
 scheduler.spawn(bill2billDriverTC,0,20);

 print(scheduler.subscribe(jpsDemoMainApp, printerDriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, otb2DriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, bcreaderDriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, bleDriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, displayDriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, gpioctrlDriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, cpgwDriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, httpServerServiceTC));
 print(scheduler.subscribe(jpsDemoMainApp, httpClientServiceTC));
 print(scheduler.subscribe(jpsDemoMainApp, tariffsServiceTC));
 print(scheduler.subscribe(jpsDemoMainApp, sgpDriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, paymentServiceTC));
 print(scheduler.subscribe(jpsDemoMainApp, localdbServiceTC));
 print(scheduler.subscribe(jpsDemoMainApp, proxyreaderDriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, proxyrdrwrtrDriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, outschedServiceTC));
 print(scheduler.subscribe(jpsDemoMainApp, usrpassServiceTC));
 print(scheduler.subscribe(jpsDemoMainApp, billsdispenserDriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, barrierDriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, jblServiceTC));
 print(scheduler.subscribe(jpsDemoMainApp, fiscalprinterDriverTC));
 print(scheduler.subscribe(jpsDemoMainApp, bill2billDriverTC));
 
 scheduler.setTickPeriod_ms(100);

 while(true) do
  if(scheduler.pulse(1) == true) then
    print("scheduler: exiting...");
    return;
  end
  --This is the real tick timer:
  sleep_ms(100);
 end
 ------------------------------------------------------------------------