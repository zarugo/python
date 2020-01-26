/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
	'use strict';

	angular.module('JPSAdmin.pages.cashier')
	.service('CtrlBoardService', function () {
		'use strict';
		
		//
		this.execCtrlBoardAct = function (callArgs) {
			
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
	.controller('CashierCtrlBoardCtrl', CashierCtrlBoardCtrl);

	/** @ngInject */
	function CashierCtrlBoardCtrl($rootScope, $scope, CtrlBoardService, baConfig, baUtil) {
		$scope.busy = false;
		
		$scope.payData = { amnt: 0.0 , mode: 2, algo: 1, mcng: 50, mpcs:50, cngonabrt: 1 };
		
				
		$scope.pay = function() {
			var msg = "Starting "+ payData.amnt + " payment";
			var funcToCall = CtrlBoardService.execCtrlBoardAct;
			var argsToPass = {rootScope:$rootScope,
			                  ctrlScope:$scope,
							  cmd:"pst",
							  args:[payData.amnt,payData.mode,payData.algo,payData.mcng,payData.mpcs,payData.cngonabrt]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};
	}
})();
