/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
  //'use strict';

  angular.module('JPSAdmin.pages.administration.terminal')
	  .constant("menu", [
				{cmd:"'gal'", descr:"Acquire all active alarms from the peripheral", args:[]},
				{cmd:"'ptt'", descr:"Print a test ticket", args:[]},
				{cmd:"'css'", descr:"Get Cash Snapshot", args:[]},
				{cmd:"'pst'", descr:"Start a payment session", args:["amount", "mode (-1 -> Use Cfg, 0 ->Cash, 1 ->Pos, 2 ->CashPos)", "algorithm (-1 ->Use Cfg, 0 ->MinPcs, 1 ->BalPcs)", "max change (-2 ->Unlimited, -1 ->Use Cfg)", "max pieces (-2 ->Unlimited, -1 ->Use Cfg)", "enable change on abort (-1 ->Use Cfg, 0 -> disabled, 1 -> enabled)"]},
				{cmd:"'cpa'", descr:"Change a payment amount", args:["amount"]},
				{cmd:"'psp'", descr:"Stop a payment session", args:["algorithm (-1 ->Use Cfg, 0 ->MinPcs, 1 ->BalPcs)", "max change (-2 ->Unlimited, -1 ->Use Cfg)", "max pieces (-2 ->Unlimited, -1 ->Use Cfg)", "enable change on abort (-1 ->Use Cfg, 0 -> disabled, 1 -> enabled)"]},
				{cmd:"'gvc'", descr:"Give change command", args:["amount","algorithm (-1 ->Use Cfg, 0 ->MinPcs, 1 ->BalPcs)", "max change (-2 ->Unlimited, -1 ->Use Cfg)", "max pieces (-2 ->Unlimited, -1 ->Use Cfg)"]},
				{cmd:"'gps'", descr:"Get Payment Status", args:[]},
				{cmd:"'eca'", descr:"Exec Cashier Activity", args:["ctxt ('DISP', 'RELD', 'REPL' or 'EPTY')", "type ('Coin' or 'Bill')", "idx", "qtty"]},
				{cmd:"'gis'", descr:"Get IO Snapshot", args:[]},
				{cmd:"'iof'", descr:"Execute IO Action", args:["funct ('OpenShutter')"]},
				{cmd:"'gos'", descr:"Get Output Scheduler Status", args:[]},
				{cmd:"'swa'", descr:"Set When Activity On Output Scheduler", args:["entryid", "whenid", "day (Mon -> 1, Tue -> 2, Wed -> 3, Thu -> 4, Fri -> 5, Sat -> 6, Sun -> 7, Bsn -> 8, All -> 9)", "enab", "time (hh:mm)", "mode ('SetSingle':0, 'RstSingle':1, 'ClnSingle':2, 'SetAll':3, 'RstAll':4, 'ClnAll':5)"]},
				{cmd:"'ssa'", descr:"Set Special Day Activity On Output Scheduler", args:["entryid", "spedayid", "date (dd/mm/yy)", "descr ('New Year')", "enab", "periodic", "mode ('SetSingle':0, 'RstSingle':1, 'ClnSingle':2, 'SetAll':3, 'RstAll':4, 'ClnAll':5)"]},
				{cmd:"'gjs'", descr:"Get JBL Service Status", args:[]},
				{cmd:"'rbt'", descr:"Software Shutdown/Reboot", args:["mode (0 -> Software Quit, 1 ->Software Reboot, 2 ->Hardware Reboot, 3 -> Hardware Power Off)"]},
				{cmd:"'ddl'", descr:"Dumps Last Buffered N-Debug Logs", args:["lev (Debug -> 0, Info -> 1, Warning -> 2, Critical -> 3, Fatal -> 4)", "or mod (Application, GpioCtrlDriver, DisplayDriver etc)"]},
				{cmd:"'mtz'", descr:"Retrieve MS Time Zone", args:[]},
				{cmd:"'usn'", descr:"Set Unique Sale Number", args:["usn"]}
				])
      .controller('TerminalWinCtrl', TerminalWinCtrl);

  /** @ngInject */
  function TerminalWinCtrl($scope, menu) {
	  
      jQuery(document).ready(function($) {
		var id = 1;
		$(".terminal" ).terminal(function(command, term) {
			if(command.length > 0)
			{
				if((command == "?") || (command == "??"))
				{
					term.clear();
					for(var i=0;i<menu.length; ++i) {
					   var tmpStr = menu[i].cmd + " - " + menu[i].descr;
					   if(menu[i].args.length) tmpStr = tmpStr + " args:->"
					   term.echo(tmpStr,  {finalize: function(div) {div.css("color", "green");}});
					   if(command == "??"){
						   for(var j=0;j<menu[i].args.length; ++j) {
							 term.echo("        :-> " + menu[i].args[j],  {finalize: function(div) {div.css("color", "gray");}});
						   }
					   }
					}
				}
				else
				{
					var parsed_cmd = $.terminal.parse_command(command);				
					
					term.pause();
					$.jrpc("/jpsadmin/api/cmd",
						   parsed_cmd.name,
						   parsed_cmd.args,
						   function(data) {
							   term.resume();
							   term.clear();
							   if (data.error) {
								   if (data.error.error && data.error.error.message) {
									   term.error(data.error.error.message);
								   } else if (data.error.message) {
									   term.error(data.error.message);
								   } else {
									   term.error('unknow rpc error');
								   }
							   } else {
								   if (typeof data.result == 'boolean') {
									   term.echo(data.result ? 'success' : 'fail');
								   } else {
									   var len = data.result.length;
									   for(var i=0;i<len; ++i) {
										   term.echo(data.result[i]);
									   }
								   }
							   }
						   },
						   function(xhr, status, error) {								   
							   term.clear();
							   term.error('[AJAX] ' + status +
										  ' - Server reponse is: \n' +
										  xhr.responseText);
							   term.resume();
						   });
				}
			}
		}, 
		{
			greetings: "This is the jpsadmin terminal, type '?' to print the commands menu\n",
			prompt: "> "
		});
	});
  }
})();