/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
	'use strict';

	angular.module('JPSAdmin.pages.dashboard')
	.service('IOService', function () {
		'use strict';
		
		///////////////////////////////////// GET IO STATUS //////////////////////////////////////
		this.getIOStatus = function (ctrlScope) {
			
			if(ctrlScope.busyIO == true){ return;}
			
			ctrlScope.busyIO = true;

			$.jrpc("/jpsadmin/api/cmd", "gis", [], function (data) {
				
					ctrlScope.busyIO = false;
				
					if (data.error) {
						if (data.error.error && data.error.error.message) {
							alert(data.error.error.message);
						} else if (data.error.message) {
							alert(data.error.message);
						} else {
							alert('unknow rpc error');
						}
					} else {
						var _io = JSON.parse(data.result[0]);
						
						ctrlScope.halversion = _io.halversion;
						ctrlScope.somtmprt = _io.somtmprt;
						ctrlScope.contmprt = _io.contmprt;
						ctrlScope.conhumid = _io.conhumid;
						ctrlScope.inputs = _io.inputs;
						ctrlScope.outputs = _io.outputs;
						
						//Update ui;
						if(ctrlScope.isCtrlIdle()) {ctrlScope.$apply();}
					}					
				},
				function (xhr, status, error) {
					alert('[AJAX] ' + status + ' - Server reponse is: \n' + xhr.responseText);
					ctrlScope.busyIO = false;
				}
			);
		}
		
		///////////////////////////////////// GET OUTPUT SCHEDULER STATUS //////////////////////////////////////
		this.getOSCStatus = function (ctrlScope) {
			
			if(ctrlScope.busyOSC == true){ return;}
			
			ctrlScope.busyOSC = true;

			$.jrpc("/jpsadmin/api/cmd", "gos", [], function (data) {
				
					ctrlScope.busyOSC = false;
				
					if (data.error) {
						if (data.error.error && data.error.error.message) {
							alert(data.error.error.message);
						} else if (data.error.message) {
							alert(data.error.message);
						} else {
							alert('unknow rpc error');
						}
					} else {
						var _osc = JSON.parse(data.result[0]);
						
						ctrlScope.activities = _osc.activities;
						
						//Update ui;
						if(ctrlScope.isCtrlIdle()) {ctrlScope.$apply();}
					}
				},
				function (xhr, status, error) {
					alert('[AJAX] ' + status + ' - Server reponse is: \n' + xhr.responseText);
					ctrlScope.busyOSC = false;
				}
			);
		}
		
		///////////////////////////////////// EXECUTE IO ACTIONS //////////////////////////////////////
		this.execIOAct = function (callArgs) {
			
			if(callArgs.ctrlScope.busyIO == true){ return;}
						
			callArgs.ctrlScope.busyIO = true;
			
			var wtMsg = callArgs.cmd;
			
			for (var i = 0; i < callArgs.args.length; i++) { 
				wtMsg += " " + callArgs.args[i];
			}
			
			callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalWt, wtMsg, function(){}, {});

			$.jrpc("/jpsadmin/api/cmd", callArgs.cmd, callArgs.args, function (data) {
				
					if (data.error) {
						if (data.error.error && data.error.error.message) { alert(data.error.error.message); }
						else if (data.error.message) 					  { alert(data.error.message); }
						else 											  { alert('unknow rpc error'); }
					} 
					else {
						callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
						callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, data.result[0], function(){}, {});
					}
					
					callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
					callArgs.ctrlScope.busyIO = false;
				},
				function (xhr, status, error) {
					alert('[AJAX] ' + status + ' - Server reponse is: \n' + xhr.responseText);
					callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
					callArgs.ctrlScope.busyIO = false;
				}
			);
		}

		///////////////////////////////////// UPDATE ACTIVITY //////////////////////////////////////		
		this.updateAct = function (callArgs) {
			
			if(callArgs.ctrlScope.busyOSC == true){ return;}
						
			callArgs.ctrlScope.busyOSC = true;
			
			var wtMsg = callArgs.cmd;
			
			for (var i = 0; i < callArgs.args.length; i++) { 
				wtMsg += " " + callArgs.args[i];
			}
			
			//Save last selected tabs to be restored:
			callArgs.ctrlScope.levsActiveTabBkp = Object.assign([], callArgs.ctrlScope.levsActiveTab);
			
			callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalWt, wtMsg, function(){}, {});

			$.jrpc("/jpsadmin/api/cmd", callArgs.cmd, callArgs.args, function (data) {
				
					if (data.error) {
						if (data.error.error && data.error.error.message) { alert(data.error.error.message); }
						else if (data.error.message) 					  { alert(data.error.message); }
						else 											  { alert('unknow rpc error'); }
					} 
					else {						
						if((data.result[0] == "Succeded") && (data.result.length > 1))
						{
							var _osc = JSON.parse(data.result[1]);
							callArgs.ctrlScope.activities = _osc.activities;
						}
						callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
						callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, data.result[0], callArgs.ctrlScope.setLevTabSlctd, {delay:250,ctrlScope:callArgs.ctrlScope});
					}
					
					callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, true);
					callArgs.ctrlScope.busyOSC = false;
				},
				function (xhr, status, error) {
					alert('[AJAX] ' + status + ' - Server reponse is: \n' + xhr.responseText);
					callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
					callArgs.ctrlScope.busyOSC = false;
				}
			);
		}
	})
	.controller('DashboardIoPanelCtrl', DashboardIoPanelCtrl);

	/** @ngInject */
	function DashboardIoPanelCtrl($rootScope, $scope, IOService, editableOptions, editableThemes) {
		$scope.days = [ 'None', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Bsn', 'All'];
		$scope.setmodes =    {'SetSingle':0, 'RstSingle':1, 'ClnSingle':2, 'CkSingle':3, 'SetAll':4    , 'RstAll':5     , 'ClnAll':6    , 'CkAll':7     };
		$scope.setmodemsgs = ['Updating'   , 'Resetting'  , 'Cleaning'   , 'Checking'  , 'Updating All', 'Resetting All', 'Cleaning All', 'Checking All'];
		$scope.busyIO = false;	
		$scope.busyOSC = false;
		$scope.levsActiveTabBkp = ["",""];
		$scope.levsActiveTab = ["",""];
		
		/////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////// UTILITIES ////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////

		////////////////////////////////////////// GET DAY NAME FROM INDEX ////////////////////////////////////
		$scope.getDayFrmIdx = function(dayidx){
		  if((dayidx) && ($scope.days.length) && (dayidx < $scope.days.length)) {
			return $scope.days[dayidx];
		  }
			
		  return 'None';
		};
		
		////////////////////////////////////////// GET INDEX FROM DAY NAME ////////////////////////////////////
		$scope.getIdxFromDay = function(day){
		  if($scope.days.indexOf(day))
		  {
			return $scope.days.indexOf(day);
		  }
		  
		  return 0;
		};
		
		////////////////////////////////////////// CHECK TIME FORMAT //////////////////////////////////////////
		$scope.checkTime = function(time) {
		   var timeFrmt = new RegExp("^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$");
		   if(timeFrmt.test(time)){
				return "";
		   }
		   return "!Valid time format is 'hh:mm'!";
		};
		
		////////////////////////////////////////// CHECK DATE FORMAT //////////////////////////////////////////
		$scope.checkDate = function(date) {
		   var dateFrmt = new RegExp("^(3[01]|[12][0-9]|0[1-9])/(1[0-2]|0[1-9])/[0-9][0-9]$");
		   if(dateFrmt.test(date)){
				return "";
		   }
		   return "!Valid date format is 'dd/mm/yy'!";
		};

		////////////////////////////////// TRACKS IO SCHED ACTIVE TABS BY LEVEL ////////////////////////////////
		$scope.levTabSlctd = function(lev, actTab) {
		  $scope.levsActiveTab[lev] = actTab;
		};

		////////////////////////////////// FORCES A TAB ACTIVE RESTORE (WORK AROUND) ////////////////////////////////
		$scope.setLevTabSlctd = function(args) {
			var delay = args.delay;
			var ctrlScope = args.ctrlScope;
			
			//10 seconds delay
			setTimeout(function(){
				for (var i = 0; i < ctrlScope.levsActiveTabBkp.length; i++) {
					var tab = document.getElementById(ctrlScope.levsActiveTabBkp[i]);
					var tablnk = tab.firstElementChild;
					tablnk.click();
				}
			}, delay );
		};
		
		////////////////////////////////////////// CONTROLLER IS IDLE CHECK ////////////////////////////////////
		$scope.isCtrlIdle = function () {			
			if(($scope.busyIO == false) && ($scope.busyOSC == false)){ return true; }			
			return false;
		};
		
		////////////////////////////////////////// REFRESH ALL DATA ////////////////////////////////////
		$scope.refreshAllData = function () {
			IOService.getIOStatus($scope);
			IOService.getOSCStatus($scope);
		};
		
		////////////////////////////////////////// REFRESH IO DATA ////////////////////////////////////
		$scope.refreshIOData = function () {
			IOService.getIOStatus($scope);
		};

		////////////////////////////////////////// REFRESH OUTSCHED DATA ////////////////////////////////////
		$scope.refreshOSCData = function () {
			IOService.getOSCStatus($scope);
		};
		
		////////////////////////////////////////// CURRENT USER HAS PERMISSIONs ////////////////////////////////////
		$scope.hasCrtclOpPerm = function() {
			var role = $rootScope.currOperator.role;
			return ((role === 'Administrator') || (role === 'Maintainer'));
		};
		
		//////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////CTRL ACTIONS//////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////////////////////////
		
		////////////////////////////////////////// EXECUTE ACTION ////////////////////////////////////
		$scope.execAction = function(action) {
			var msg = "Executing '" + action + "' action!!!";
			var funcToCall = IOService.execIOAct;
			var argsToPass = {rootScope:$rootScope,
			                  ctrlScope:$scope,
							  cmd:"iof",
							  args:[action]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};
				
		////////////////////////////////////////// SAVE ACTIVITY.WHEN ////////////////////////////////////
		$scope.onWhenSaveBtn = function(entryid, whenidx, rowform, mode) {			
			var callArgs = rowform.$data;
			var func    = $scope.activities[entryid].func;
			var setmodesmsg = $scope.setmodemsgs[mode];
			var msg = setmodesmsg + " when ("+ whenidx +") for '" + (func) +"'";
			var funcToCall = IOService.updateAct;
						
			$scope.activities[entryid].whenlist[whenidx].day    = $scope.getIdxFromDay(callArgs.day);
			$scope.activities[entryid].whenlist[whenidx].time   = callArgs.time;
			$scope.activities[entryid].whenlist[whenidx].enab   = callArgs.enab;
			
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  cmd:"swa",
							  args:[entryid,whenidx,$scope.getIdxFromDay(callArgs.day),callArgs.enab,callArgs.time,mode]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
									
			rowform.$cancel();
		};
		
		////////////////////////////////////////// SAVE ALL ACTIVITY.WHEN ////////////////////////////////////
		$scope.onWhenSaveAllBtn = function(entryid, whenidx, mode) {
			var callArgs = $scope.activities[entryid].whenlist[whenidx];
			var func    = $scope.activities[entryid].func;
			var setmodesmsg = $scope.setmodemsgs[mode];
			var msg = setmodesmsg + " when for '" + (func) +"'";
			var funcToCall = IOService.updateAct;
						
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  cmd:"swa",
							  args:[entryid,whenidx,$scope.getIdxFromDay(callArgs.day),callArgs.enab,callArgs.time,mode]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};
		
		////////////////////////////////////////// UPDATE ACTIVITY.SPEC DAY ////////////////////////////////////
		$scope.onSpecDaySaveBtn = function(entryid, specdayidx, rowform, mode) {
			var callArgs = rowform.$data;
			var func    = $scope.activities[entryid].func;
			var setmodesmsg = $scope.setmodemsgs[mode];
			var msg = setmodesmsg + " spec day ("+ specdayidx +") for '" + (func) +"'";
			var funcToCall = IOService.updateAct;
						
			$scope.activities[entryid].specdaylist[specdayidx].date = callArgs.date;
			$scope.activities[entryid].specdaylist[specdayidx].descr = callArgs.descr;
			$scope.activities[entryid].specdaylist[specdayidx].enab = callArgs.enab;
			$scope.activities[entryid].specdaylist[specdayidx].periodic = callArgs.periodic;
			
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  cmd:"ssa",
							  args:[entryid,specdayidx,callArgs.date,callArgs.descr,callArgs.enab,callArgs.periodic, mode]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
									
			rowform.$cancel();
		};
		
		////////////////////////////////////////// CLEAN ACTIVITY.SPEC DAY ////////////////////////////////////
		$scope.onSpecDaySaveAllBtn = function(entryid, specdayidx, mode) {
			var callArgs = $scope.activities[entryid].specdaylist[specdayidx];
			var func    = $scope.activities[entryid].func;
			var setmodesmsg = $scope.setmodemsgs[mode];
			var msg = setmodesmsg + " spec day '" + (func) +"'";
			var funcToCall = IOService.updateAct;
									
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  cmd:"ssa",
							  args:[entryid,specdayidx,callArgs.date,callArgs.descr,callArgs.enab,callArgs.periodic,mode]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};
		
		$scope.refreshAllData();
		
		editableOptions.theme = 'bs3';
		editableThemes['bs3'].submitTpl = '<button type="submit" class="btn btn-primary btn-with-icon"><i class="ion-checkmark-round"></i></button>';
		editableThemes['bs3'].cancelTpl = '<button type="button" ng-click="$form.$cancel()" class="btn btn-default btn-with-icon"><i class="ion-close-round"></i></button>';
	}
})();
