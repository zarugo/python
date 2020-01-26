/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
  'use strict';

  angular.module('JPSAdmin.theme.components')
      .controller('MsgCenterCtrl', MsgCenterCtrl);

  /** @ngInject */
  function MsgCenterCtrl($rootScope, $scope, $timeout, $sce) {
	 
	$scope.alarms = [];
	 
	$scope.getAlarms = function () {
		
		$.jrpc("/jpsadmin/api/cmd",
			"gal",
			[],
			function (data) {
				
				if (data.error) {
					if (data.error.error && data.error.error.message) {
						alert(data.error.error.message);
					} else if (data.error.message) {
						alert(data.error.message);
					} else {
						alert('unknow rpc error');
					}
				} else {
					$scope.alarms = [];
					$scope.alarms = JSON.parse(data.result[0]);
					$scope.$apply();
				}
			},
			function (xhr, status, error) {
			alert('[AJAX] ' + status + ' - Server reponse is: \n' + xhr.responseText);
		});
	}
	
	//Always call to initialize the data:
	$timeout(function () {
		$scope.getAlarms();
    }, 1000);	
	
	
	////////////////////////////////////////// EXECUTE ACTION ////////////////////////////////////
	$scope.details = function(id, details) {
		var details_tr = $scope.$eval("'_GENERIC_DETAILS_' | translate");
		var key_tr = $scope.$eval("'_GENERIC_KEY_' | translate");
		var value_tr = $scope.$eval("'_GENERIC_VALUE_' | translate");
		var msg = "<div><center><font size='4'><b>"+details_tr+"</b></font></center></div><div></div>"
		var tab = "<table class='table table-bordered table-hover table-condensed'><tr><td><b>"+key_tr+"</b></td><td><b>"+value_tr+"</b></td></tr>";
		tab = tab + "<tr><td><b>" + id +"</b></td><td><b>" + details + "</b></td></tr>";
		tab = tab + "</table>";		
		msg = msg + tab;		
		$rootScope.showGlbModal($rootScope.glbModalRes, msg, function(){}, {});
	};
	
  }
})();