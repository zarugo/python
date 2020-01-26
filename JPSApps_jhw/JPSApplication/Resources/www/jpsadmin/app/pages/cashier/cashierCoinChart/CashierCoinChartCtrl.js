/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
	'use strict';

	angular.module('JPSAdmin.pages.cashier')
	.service('CoinsService', function () {
		'use strict';
		
		
		//
		function updateCoinCharts(ctrlScope, coinColor) {
			var _coincharts = [];
		
			// response is an array of both resolved promises
			angular.forEach(ctrlScope.coins, function (item, key) {
								
				var _coinchart = {
					color: coinColor,
					id: item.id,
					descr: (item.value == 0 ? ("") : ("" + (item.id+1) + ": ")),
					value: (item.value == 0 ? ("") : ("" + item.value)),
					currency: item.currency,
					pieces: item.quantity,
					total: item.cumval,
					capacity: item.capacity,
					percent: ""+((item.quantity/item.capacity)*100),
					icon: 'money',
					details: item.details
				}

				_coincharts.push(_coinchart);
			});
			
			ctrlScope.coincharts = _coincharts;			
			ctrlScope.$apply();

			var chartDivs = $('cashier-coin-chart .pie-charts .chart');
			
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
		
		
		  $('cashier-coin-chart .pie-charts .chart').each(function(index, chart) {
			var data = $(chart).data('easyPieChart');
			data.update(ctrlScope.coincharts[index].percent);
		  });
		  
		  ctrlScope.$apply();
		}
		
		this.getCoins = function (ctrlScope, coinColor) {
			
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
						ctrlScope.coins = _cash.coins;
						
						//Update coin chart;
						updateCoinCharts(ctrlScope, coinColor);
					}
					
					ctrlScope.busy = false;
				},
				function (xhr, status, error) {
					alert('[AJAX] ' + status + ' - Server reponse is: \n' + xhr.responseText);
					ctrlScope.busy = false;
				}
			);
		}
		
		this.execCoinsAct = function (callArgs) {
			
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
		}
	})
	.controller('CashierCoinChartCtrl', CashierCoinChartCtrl);

	/** @ngInject */
	function CashierCoinChartCtrl($rootScope, $scope, CoinsService, baConfig, baUtil) {
		$scope.busy = false;	
		$scope.refreshCoinData = function () {
			CoinsService.getCoins($scope, baUtil.hexToRGB(baConfig.colors.defaultText, 0.2));
		};
		
		$scope.checkIntVal = function(value){
			if(value == null)
			return false;
			var res = !(Number.isInteger(value));
			return res;
		}
		
		$scope.dispense = function(index, formData) {
			var msg = $scope.$eval("'_MAIN_CASHIER_GENERIC_DISPENSING_'  | translate:{_1_: '"+formData.pcs+"', _2_: '"+(index)+"'}");
			var funcToCall = CoinsService.execCoinsAct;
			var argsToPass = {rootScope:$rootScope,
			                  ctrlScope:$scope,
							  cmd:"eca",
							  args:["DISP", "Coin",$scope.coincharts[index].id,formData.pcs]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};

		$scope.reload = function(index, formData) {
			var msg = $scope.$eval("'_MAIN_CASHIER_GENERIC_LOADING_'  | translate:{_1_: '"+formData.pcs+"', _2_: '"+(index)+"'}");
			var funcToCall = CoinsService.execCoinsAct;
			var argsToPass = {rootScope:$rootScope,
			                  ctrlScope:$scope,
							  cmd:"eca",
							  args:["RELD", "Coin", $scope.coincharts[index].id, formData.pcs]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};

		$scope.replace = function(index, formData) {
			var msg = $scope.$eval("'_MAIN_CASHIER_GENERIC_REPLACING_'  | translate:{_1_: '"+$scope.coincharts[index].pieces+"', _2_: '"+formData.pcs+"', _3_: '"+(index)+"'}");
			var funcToCall = CoinsService.execCoinsAct;
			var argsToPass = {rootScope:$rootScope,
			                  ctrlScope:$scope,
							  cmd:"eca",
							  args:["REPL", "Coin", $scope.coincharts[index].id, formData.pcs]};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};
		
		$scope.empty = function(index, formData) {
			
			var msg = $scope.$eval("'_MAIN_CASHIER_GENERIC_EMPTING_'  | translate:{_1_: '"+$scope.coincharts[index].pieces+"', _2_: '"+(index)+"'}");
			var funcToCall = CoinsService.execCoinsAct;
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  cmd:"eca",
							  args:["EPTY", "Coin", $scope.coincharts[index].id, 9999]};
							  
			$rootScope.showGlbModal($rootScope.glbModalConf,
					msg,
					funcToCall,
					argsToPass);			
		};
				
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
					
		$scope.refreshCoinData();
	}
})();
