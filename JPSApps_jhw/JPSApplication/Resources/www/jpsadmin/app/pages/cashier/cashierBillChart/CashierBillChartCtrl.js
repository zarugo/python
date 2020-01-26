/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
	'use strict';

	angular.module('JPSAdmin.pages.cashier')
	.service('BillsService', function () {
		'use strict';
		
		//
		function updateBillCharts(ctrlScope, billColor) {
			var _billcharts = [];
			// response is an array of both resolved promises
			angular.forEach(ctrlScope.bills, function (item, key) {
								
				var _billchart = {
					color: billColor,
					id: item.id,
					descr: (item.value == 0 ? ("") : ("" + (item.id+1) + ": ")),
					value: (item.value == 0 ? ("") : ("" + item.value)),
					currency: item.currency,
					pieces: item.quantity,
					total: item.cumval,
					capacity: item.capacity,
					percent: ""+((item.quantity/item.capacity)*100),
					icon: 'money',
					details: item.details,
					b2b:  (item.type == "bill2bill" ? true : false)
				}
				if(ctrlScope.b2b == false && _billchart.b2b){
					ctrlScope.b2b = true;
				}
				_billcharts.push(_billchart);
			});
			
			ctrlScope.billcharts = _billcharts;			
			ctrlScope.$apply();

			var chartDivs = $('cashier-bill-chart .pie-charts .chart');
			
			chartDivs.each(function () {
				var chart = $(this);
				chart.easyPieChart({
					easing: 'easeOutBounce',
					onStep: function (from, to, percent) {
						$(this.el).find('.percent').text(parseFloat(percent).toFixed(2));
					},
					barColor: chart.attr('rel'),
					trackColor: 'rgba(0,0,0,0)',
					size: 80,
					scaleLength: 0,
					animation: 2000,
					lineWidth: 9,
					lineCap: 'round',
				});
			});
		
		
		  $('cashier-bill-chart .pie-charts .chart').each(function(index, chart) {
			var data = $(chart).data('easyPieChart');
			data.update(ctrlScope.billcharts[index].percent);
		  });
		  
		  ctrlScope.$apply();
		}
		
		this.getBills = function (ctrlScope, billColor) {
			
			if(ctrlScope.busy == true){ return;}
			
			ctrlScope.busy = true;

			$.jrpc("/jpsadmin/api/cmd", "css", [], function (data) {
				
					if (data.error) {
						if (data.error.error && data.error.error.message) {
							alert(data.error.error.message);
						} else if (data.error.message) {
							alert(data.error.message);
						} else {
							alert('unknow rpc error');
						}
					} else {
						var _cash = JSON.parse(data.result[0]);
						ctrlScope.bills = _cash.bills;
						
						//Update bill chart;
						if(ctrlScope.b2b == true){
							if(data.result[0] != ctrlScope.lastBillData || ctrlScope.loadBillsTimer == undefined){
								updateBillCharts(ctrlScope, billColor);
								ctrlScope.lastBillData = data.result[0];
							}
						} else {
							updateBillCharts(ctrlScope, billColor);
						}
					}
					
					ctrlScope.busy = false;
				},
				function (xhr, status, error) {
					alert('[AJAX] ' + status + ' - Server reponse is: \n' + xhr.responseText);
					ctrlScope.busy = false;
				}
			);
		}
		
		this.execBillsAct = function (callArgs) {
			
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
						var evalmsg = data.result[0];
						try{evalmsg = callArgs.ctrlScope.$eval(evalmsg);} catch (err){console.log(err.name + ': "' + err.message);}
						if(evalmsg){data.result[0] = evalmsg;}
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

			if(callArgs.cmd == 'ldb'){
				if(callArgs.args[0] == 0) {
					if(callArgs.ctrlScope.loadBillsTimer != undefined) {clearInterval(callArgs.ctrlScope.loadBillsTimer)}
				} else { 
					//LoadBillsTimer = setInterval($scope.refreshBillData(), 2000);
					callArgs.ctrlScope.loadBillsTimer = setInterval(callArgs.ctrlScope.refreshBillData, 2000);
				}
			}
		}
		
		this.getB2BInfo = function (callArgs) {
			
			if(callArgs.ctrlScope.busy == true){ return;}
						
			callArgs.ctrlScope.busy = true;
			
			var wtMsg = callArgs.cmd;
			
			for (var i = 0; i < callArgs.args.length; i++) { 
				wtMsg += " " + callArgs.args[i];
			}
			
			callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalWt, wtMsg, function(){}, {});

			$.jrpc("/jpsadmin/api/cmd", callArgs.cmd, callArgs.args, function (data) {
				
					var hasValidRes = false;
					if (data.error) {
						if (data.error.error && data.error.error.message) { alert(data.error.error.message); }
						else if (data.error.message) 					  { alert(data.error.message); }
						else 											  { alert('unknow rpc error'); }
					} 
					else {
						if (data.result != undefined && data.result[1] != undefined) {
							callArgs.ctrlScope.B2BInfo = data.result[1];
							hasValidRes = true;
						}
						callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
						callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, data.result[0], function(){}, {});
					}
					
					callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
					callArgs.ctrlScope.busy = false;

					if(hasValidRes) { callArgs.ctrlScope.showB2BInfo(callArgs.ctrlScope.B2BInfo); }
				},
				function (xhr, status, error) {
					alert('[AJAX] ' + status + ' - Server reponse is: \n' + xhr.responseText);
					callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
					callArgs.ctrlScope.busy = false;
				}
			);
		}
	})
	.controller('CashierBillChartCtrl', CashierBillChartCtrl);

	/** @ngInject */
	function CashierBillChartCtrl($rootScope, $scope, $interval, BillsService, baConfig, baUtil) {
		$scope.busy = false;
		$scope.b2b = false;
		$scope.lastBillData;
		$scope.loadBillsTimer;
		$scope.B2BInfo = "N/A";
		$scope.refreshBillData = function () {
			BillsService.getBills($scope, baUtil.hexToRGB(baConfig.colors.defaultText, 0.2));
		};
		
		$scope.checkIntVal = function(value){
			if(value == null)
			return false;
			var res = !(Number.isInteger(value));
			return res;
		}
		
		$scope.dispense = function(index, formData) {
			var msg = $scope.$eval("'_MAIN_CASHIER_GENERIC_DISPENSING_'  | translate:{_1_: '"+formData.pcs+"', _2_: '"+(index)+"'}");
			var funcToCall = BillsService.execBillsAct;
			var argsToPass = {rootScope:$rootScope,
			                  ctrlScope:$scope,
							  cmd:"eca",
							  args:["DISP", "Bill",$scope.billcharts[index].id,formData.pcs]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};

		$scope.reload = function(index, formData) {
			var msg = $scope.$eval("'_MAIN_CASHIER_GENERIC_LOADING_'  | translate:{_1_: '"+formData.pcs+"', _2_: '"+(index)+"'}");
			var funcToCall = BillsService.execBillsAct;
			var argsToPass = {rootScope:$rootScope,
			                  ctrlScope:$scope,
							  cmd:"eca",
							  args:["RELD", "Bill", $scope.billcharts[index].id, formData.pcs]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};

		$scope.replace = function(index, formData) {
			var msg = $scope.$eval("'_MAIN_CASHIER_GENERIC_REPLACING_'  | translate:{_1_: '"+$scope.billcharts[index].pieces+"', _2_: '"+formData.pcs+"', _3_: '"+(index)+"'}");
			var funcToCall = BillsService.execBillsAct;
			var argsToPass = {rootScope:$rootScope,
			                  ctrlScope:$scope,
							  cmd:"eca",
							  args:["REPL", "Bill", $scope.billcharts[index].id, formData.pcs]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};
		
		$scope.empty = function(index, formData) {
			
			var msg = $scope.$eval("'_MAIN_CASHIER_GENERIC_EMPTING_'  | translate:{_1_: '"+$scope.billcharts[index].pieces+"', _2_: '"+(index)+"'}");
			var funcToCall = BillsService.execBillsAct;
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  cmd:"eca",
							  args:["EPTY", "Bill", $scope.billcharts[index].id, 9999]};
							  
			$rootScope.showGlbModal($rootScope.glbModalConf,
					msg,
					funcToCall,
					argsToPass);			
		};
		
		$scope.unload = function(index, formData) {
			if($scope.billcharts[index].value == 0) { return; } //no unloading for Bill Safe
			var msg = "Unload the Bill2Bill, so "+ formData.pcs + " pieces remain in Cassette-" + (index + 1);
						
			var funcToCall = BillsService.execBillsAct;
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  cmd:"eca",
							  args:["UNLD", "Bill", $scope.billcharts[index].id, formData.pcs]};
							  
			$rootScope.showGlbModal($rootScope.glbModalConf,
					msg,
					funcToCall,
					argsToPass);			
		};
		
		//Loading - enable/disable
		$scope.enable = function(opt) {
			var msg = "LOADING - enable the accepting of bills from the Bill2Bill device";
			
            if(opt == 0) { 
                msg = "STOP LOADING - disable the accepting of bills from the Bill2Bill device";
			}

			var funcToCall = BillsService.execBillsAct;
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  cmd:"ldb",
							  args:[opt]};
							  
			$rootScope.showGlbModal($rootScope.glbModalConf,
					msg,
					funcToCall,
					argsToPass);			
		};
		
		//Get Bill2Bill info
		$scope.getB2BInfo = function() {
			var msg = "Get diagnostic information for the Bill2Bill device";

			var funcToCall = BillsService.getB2BInfo;
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  cmd:"gib",
							  args:[]};
							  
			$rootScope.showGlbModal($rootScope.glbModalConf,
					msg,
					funcToCall,
					argsToPass);			
		};
		
		
		/////
		$scope.details = function(details, currency) {
			
			var details_tr = $scope.$eval("'_GENERIC_DETAILS_' | translate");
			var value_tr = $scope.$eval("'_GENERIC_VALUE_' | translate");
			var pieces_tr = $scope.$eval("'_GENERIC_PIECES_' | translate");
			var total_tr = $scope.$eval("'_GENERIC_TOT_' | translate");
			var msg = "<div><center><font size='4'>"+details_tr+"</b></font></center></div><div></div>"
			var tab = "<table class='table table-bordered table-hover table-condensed'><tr>"
			tab += "<td><b>"+value_tr+"</b></td>"
			tab += "<td><b>"+pieces_tr+"</b></td>"
			tab += "<td><b>"+total_tr+"</b></td>"
			tab += "</tr>";
			
			angular.forEach(details, function (item, key) {
				tab = tab + "<tr><td><b>" + item.value + " " + currency +"</b></td><td><b>" + item.quantity + "</b></td><td><b>"  + item.cumval + " " + currency +"</b></td></tr>";
			});
			
			tab = tab + "</table>";
			
			msg = msg + tab;
			
			$rootScope.showGlbModal($rootScope.glbModalRes, msg, function(){}, {});
		};

		$scope.showB2BInfo = function(details) {
			
			var msg = "<div><center><font size='4'><b>Bill2Bill Information</b></font></center></div><div></div>"
			var tab = "<table class='table table-bordered table-hover table-condensed'><tr style='text-align: left'><td style='text-align: left'><b>Parameter</b></td><td><b>Value</b></td></tr>";
			
			var b2bObj = JSON.parse(details);
			
			b2bObj.bill2bill.forEach(function(item){
				for(const [key, value] of Object.entries(item)) {
					tab = tab + "<tr><td style='text-align: left'><b>" + key  + "</b></td><td><b>" + value + "</b></td></tr>";
				}
			})
			tab = tab + "</table>";
			
			msg = msg + tab;
			
			$rootScope.showGlbModal($rootScope.glbModalRes, msg, function(){}, {});
		};
				
		$scope.refreshBillData();
	}
})();
