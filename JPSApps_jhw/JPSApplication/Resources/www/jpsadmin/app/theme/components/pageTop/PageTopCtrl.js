/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
  'use strict';

  angular.module('JPSAdmin.theme.components')
	.constant("versionUrl", "/jpsadmin/api/version")
	.constant("logoutUrl", "/jpsadmin/api/logout")
	.constant("operatorsUrl", "/jpsadmin/api/operators")
    .controller('PageTopCtrl', PageTopCtrl);

  /** @ngInject */
  function PageTopCtrl($rootScope, $scope, $cookies, $http, $window, $timeout, versionUrl, logoutUrl, operatorsUrl)
  {
	$scope.version = "";
	  
	////////////////////////////////////////// APPLICATION VERSION ////////////////////////////////////
	$scope.getVersion = function() {
		
		$http.get(versionUrl, {
				withCredentials: true
			}).then(function successCallback(response) {
				// this callback will be called asynchronously
				// when the response is available
				$scope.version = response.data;
				$rootScope.version = response.data;
			}, function errorCallback(response) {
			// called asynchronously if an error occurs
			// or server returns response with an error status.
				$scope.version = "Not Available";
				$rootScope.version = "Not Available";
			});
    };
	//////////////////////////////////////////////////////////////////////////////////////////////	
	  
	////////////////////////////////////////// SIGN OUT OPERATOR ////////////////////////////////////
    $scope.signOut = function() {
		
		var _id = $cookies.getObject("id");
		var _sessTok = $cookies.getObject("sessTok");
		
		$http.post(logoutUrl, {
				id: _id,
				sessTok: "" + _sessTok
			}, {
				withCredentials: true
			}).then(function successCallback(response) {
				// this callback will be called asynchronously
				// when the response is available
				$window.location.reload();
			}, function errorCallback(response) {
			// called asynchronously if an error occurs
			// or server returns response with an error status.
				$window.location.reload();
			});
    };
	//////////////////////////////////////////////////////////////////////////////////////////////	
	
	////////////////////////////////////////// READ OPERATOR ////////////////////////////////////
	$scope.readOperator = function()
	{
		$rootScope .showGlbModal($rootScope.glbModalWt, "", function(){}, {});
		
		$http.get(operatorsUrl+'/'+$rootScope.currOperator.id, {withCredentials : true})
		.success(function (data) {
			
			var details_tr = $scope.$eval("'_GENERIC_DETAILS_' | translate");
			var key_tr = $scope.$eval("'_GENERIC_KEY_' | translate");
			var value_tr = $scope.$eval("'_GENERIC_VALUE_' | translate");
			var msg = "<div><center><font size='4'>"+details_tr+"</b></font></center></div><div></div>"
			var tab = "<table class='table table-bordered table-hover table-condensed'><tr>"
			tab += "<td><b>"+key_tr+"</b></td>"
			tab += "<td><b>"+value_tr+"</b></td>"
			tab += "</tr>";
			
			for(const [key, value] of Object.entries(data)) {
				tab = tab + "<tr><td><b>" + key +"</b></td><td><b>" + value +"</b></td></tr>";
			}
			
			tab = tab + "</table>";
			msg = msg + tab;
			
			$rootScope.hideGlbModal($rootScope.glbModalWt, false);
			$rootScope.showGlbModal($rootScope.glbModalRes, msg, function(){}, {});
		})
		.error(function (error) {			
			$rootScope.hideGlbModal($rootScope.glbModalWt, false);
			$rootScope.showGlbModal($rootScope.glbModalRes, error, function(){}, {});
		});
	}
	//////////////////////////////////////////////////////////////////////////////////////////////	
	
	//Always call to initialize the data:
	$timeout(function () {
		$scope.getVersion();
    }, 1000);
  }
})();