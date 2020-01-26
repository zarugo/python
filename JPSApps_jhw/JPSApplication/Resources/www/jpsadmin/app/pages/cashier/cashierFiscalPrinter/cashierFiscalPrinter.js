/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
	'use strict';

	angular.module('JPSAdmin.pages.cashier')
	.service('FiscalPrinterService', function () {
		'use strict';
		
		this.getFiscalPrinter = function (ctrlScope) {
			
			if(ctrlScope.busy == true){ return;}
			
			ctrlScope.busy = true;

			$.jrpc("/jpsadmin/api/cmd", "cfp", [], function (data) {
				
					if (data.error) {
						if (data.error.error && data.error.error.message) {
							alert(data.error.error.message);
						} else if (data.error.message) {
							alert(data.error.message);
						} else {
							alert('unknow rpc error');
						}
					} else {
						if (data.result != undefined && data.result[0] != undefined) {
							ctrlScope.showFiscalPrinter = (data.result[0] == 'true');
						}
						else{
							ctrlScope.showFiscalPrinter = false;
						}
						
						if (data.result != undefined && data.result[1] != undefined) {
							ctrlScope.showFiscalPrinterUSN = (data.result[1] == 'true');
							
							if(!ctrlScope.showFiscalPrinter) ctrlScope.showFiscalPrinterUSN = false;
						}
						else{
							ctrlScope.showFiscalPrinterUSN = false;
						}
						
						if (data.result != undefined && data.result[2] != undefined) {
							ctrlScope.valueUSN = parseInt(data.result[2], 10);
						}
						
						if (data.result != undefined && data.result[3] != undefined) {
							ctrlScope.fiscPrinterTotalAmount = data.result[3];
						}
						
						if (data.result != undefined && data.result[4] != undefined) {
							ctrlScope.snapShotTotalAmount = data.result[4];
						}
						
						if (data.result != undefined && data.result[5] != undefined) {
							ctrlScope.showFiscalPrinterTotal = (data.result[5] == 'true');
							
							ctrlScope.showFiscalPrinterTotal = ctrlScope.showFiscalPrinterTotal || ctrlScope.showFiscalPrinterUSN;
							if(!ctrlScope.showFiscalPrinter) ctrlScope.showFiscalPrinterTotal = false;
						}
						else{
							ctrlScope.showFiscalPrinterTotal = false;
						}
					}
					
					ctrlScope.busy = false;
				},
				
			);
		}
		
		this.printReport = function (callArgs) {
			
			if(callArgs.ctrlScope.busy == true){ return;}
						
			callArgs.ctrlScope.busy = true;
			
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
					callArgs.ctrlScope.busy = false;
				},
				function (xhr, status, error) {
					alert('[AJAX] ' + status + ' - Server reponse is: \n' + xhr.responseText);
					callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
					callArgs.ctrlScope.busy = false;
				}
			);
		}
		
		this.setUSN = function (callArgs) {
			
			if(callArgs.ctrlScope.busy == true){ return;}
						
			callArgs.ctrlScope.busy = true;
			
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
					callArgs.ctrlScope.busy = false;
				},
				function (xhr, status, error) {
					alert('[AJAX] ' + status + ' - Server reponse is: \n' + xhr.responseText);
					callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
					callArgs.ctrlScope.busy = false;
				}
			);
		}
	})
	.controller('CashierFiscalPrinterCtrl', CashierFiscalPrinterCtrl);

	/** @ngInject */
	function CashierFiscalPrinterCtrl($rootScope, $scope, FiscalPrinterService, baConfig, baUtil) {
		$scope.busy = false;	
		$scope.showFiscalPrinter = false;
		$scope.showFiscalPrinterUSN = false;
		$scope.showFiscalPrinterTotal = false;
		
		$scope.checkFiscalPrinterCtrl = function () {
			FiscalPrinterService.getFiscalPrinter($scope);
		};
		
		$scope.print = function(type) {
			var msg = "Printing fiscal report type " + type + "!!!";
			var funcToCall = FiscalPrinterService.printReport;
			var argsToPass = {rootScope:$rootScope,
			                  ctrlScope:$scope,
							  cmd:"pfr",
							  args:[type]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};
		
		$scope.setUSN = function(value) {
			var msg = "Set Unique Sale Number to " + value + "!!!";
			var funcToCall = FiscalPrinterService.setUSN;
			var argsToPass = {rootScope:$rootScope,
			                  ctrlScope:$scope,
							  cmd:"usn",
							  args:[value]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};
		
		$scope.checkIntVal = function(value){
            if(value == null || value == undefined) return true;
			if(!(Number.isInteger(value))) return true;
        	
            return false;
        }        

		$scope.checkFiscalPrinterCtrl();
	}
})();
