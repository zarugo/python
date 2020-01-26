/**
 * @author v.lugovsky
 * created on 16.12.2015
 */
(function () {
  'use strict';

  angular.module('JPSAdmin.pages.administration.usrpasses')
	.constant("usrpassesUrl", "/jpsadmin/api/usrpasses")
    .controller('UsrPassesPageCtrl', UsrPassesPageCtrl);

  /** @ngInject */
  function UsrPassesPageCtrl($rootScope, $scope, $filter,  $http, usrpassesUrl, editableOptions, editableThemes) {

	$scope.deepview = false;
	
	$scope.usrpasses=[];

    $scope.statuses = [ '', 'RESET', 'IN', 'OUT'];

    $scope.showStatuses = function(usrpass) {
      if(usrpass.status && $scope.statuses.length) {
        var selected = usrpass.status;
        return selected.length ? selected : 'Not set';
      }
	  else {
		  return 'Not set';
	  }
    };
	
	////////////////////////////////////////// CRUD IMPLEMENTATION ////////////////////////////////////
	
	////////////////////////////////////////// READ ALL USRPASSES ////////////////////////////////////
	$scope.readUsrPasses = function()
	{
		$http.get(usrpassesUrl, {withCredentials : true})
		.success(function (data) {
			$scope.usrpasses = data;
		})
		.error(function (error) {
			alert(error);
		});
	}
	//Always call to initialize the data:
	$scope.readUsrPasses();
	//////////////////////////////////////////////////////////////////////////////////////////////
	
	////////////////////////////////////////// SEARCH ALL USRPASSES ////////////////////////////////////
	$scope.searchUsrPasses = function(uid)
	{
		var wtMsg = "Searching for usrpasses '" + (uid) +"'";
		$rootScope.showGlbModal($rootScope.glbModalWt, wtMsg, function(){}, {});
		
		$http.get(usrpassesUrl+'/'+uid, {withCredentials : true})
		.success(function (data) {
			$scope.usrpasses = data;
			$rootScope.hideGlbModal($rootScope.glbModalWt, false);
		})
		.error(function (error) {
			$rootScope.hideGlbModal($rootScope.glbModalWt, false);
			$rootScope.showGlbModal($rootScope.glbModalRes, "Failed:" + error, function(){}, {});
		});
	}
	
	////////////////////////////////////////// READ USRPASS ////////////////////////////////////
	$scope.readUsrPass = function(uid)
	{
		$http.get(usrpassesUrl+'/'+uid, {withCredentials : true})
		.success(function (data) {
			$scope.usrpasses=[];
			$scope.usrpasses[0] = data;
		})
		.error(function (error) {
			alert(error);
		});
	}
	//////////////////////////////////////////////////////////////////////////////////////////////	

	////////////////////////////////////////// CREATE/UPDATE USRPASS ////////////////////////////////////
	$scope.updateUsrPass = function(callArgs) {
		
		var wtMsg = "Creating/Updating usrpass '" + (callArgs.frmDt.uid) +"'";
		var isCrt = callArgs.frmDt.iscrt;
		
		$scope.usrpasses[callArgs.idx].uid      = callArgs.frmDt.uid;
		$scope.usrpasses[callArgs.idx].usrname 	= callArgs.frmDt.usrname;
		$scope.usrpasses[callArgs.idx].usrtype 	= callArgs.frmDt.usrtype;
		$scope.usrpasses[callArgs.idx].prdtype  = callArgs.frmDt.prdtype;
		$scope.usrpasses[callArgs.idx].status   = callArgs.frmDt.status;
		$scope.usrpasses[callArgs.idx].balance  = callArgs.frmDt.balance;
		$scope.usrpasses[callArgs.idx].enabled  = (callArgs.frmDt.enabled > 0) ? true :false;
		$scope.usrpasses[callArgs.idx].stvldty  = $filter('date')(callArgs.frmDt.stvldty, "dd-MM-yyyyTHH:mm:ss");
		$scope.usrpasses[callArgs.idx].edvldty  = $filter('date')(callArgs.frmDt.edvldty, "dd-MM-yyyyTHH:mm:ss");
		$scope.usrpasses[callArgs.idx].rawdata  = callArgs.frmDt.rawdata;
		$scope.usrpasses[callArgs.idx].pinnumb  = md5(callArgs.frmDt.pinnumb).toUpperCase();
		$scope.usrpasses[callArgs.idx].pinattempts  = callArgs.frmDt.pinattempts;
		$scope.usrpasses[callArgs.idx].maxattempts  = callArgs.frmDt.maxattempts;
		$scope.usrpasses[callArgs.idx].reserved  = callArgs.frmDt.reserved;
		
		$rootScope.showGlbModal($rootScope.glbModalWt, wtMsg, function(){}, {});
		
		if(isCrt == true)
		{
			$http.post(usrpassesUrl+'/'+$scope.usrpasses[callArgs.idx].uid, $scope.usrpasses[callArgs.idx],{withCredentials : true})
			.success(function (data) {
				$scope.usrpasses[callArgs.idx] = data;
				$rootScope.hideGlbModal($rootScope.glbModalWt, false);
				$rootScope.showGlbModal($rootScope.glbModalRes, "Succeeded", function(){}, {});
			})
			.error(function (error) {
				$rootScope.hideGlbModal($rootScope.glbModalWt, false);
				$rootScope.showGlbModal($rootScope.glbModalRes, "Failed", function(){}, {});
			});			
		}
		else
		{
			$http.put(usrpassesUrl+'/'+$scope.usrpasses[callArgs.idx].uid, $scope.usrpasses[callArgs.idx], {withCredentials : true})
			.success(function (data) {
				$scope.usrpasses[callArgs.idx] = data;
				$rootScope.hideGlbModal($rootScope.glbModalWt, false);
				$rootScope.showGlbModal($rootScope.glbModalRes, "Succeeded", function(){}, {});
			})
			.error(function (error) {
				$rootScope.hideGlbModal($rootScope.glbModalWt, false);
				$rootScope.showGlbModal($rootScope.glbModalRes, "Failed", function(){}, {});
			});			
		}
		
		if(angular.isUndefined($scope.inserted) == false){
		  delete $scope.inserted;
		}
    };
	
    ////////////////////////////////////////// DELETE USRPASS ////////////////////////////////////
	$scope.removeUsrPass = function(callArgs) {
		var index = callArgs.idx;
		var wtMsg = "Deleting usrpass '" + ($scope.usrpasses[index].uid) +"'";
		
		$rootScope.showGlbModal($rootScope.glbModalWt, wtMsg, function(){}, {});
		
		$http.delete(usrpassesUrl+'/'+$scope.usrpasses[index].uid, {withCredentials : true})
			.success(function (data) {
				$scope.usrpasses.splice(index, 1);
				$rootScope.hideGlbModal($rootScope.glbModalWt, false);
				$rootScope.showGlbModal($rootScope.glbModalRes, "Succeeded", function(){}, {});
			})
			.error(function (error) {
				$rootScope.hideGlbModal($rootScope.glbModalWt, false);
				$rootScope.showGlbModal($rootScope.glbModalRes, "Failed", function(){}, {});
			});
    };

	///////////////////////////////////////// BUTTONS CALLBACK ////////////////////////////////////
	$scope.onSaveBtn = function(index, formData)
	{
		var funcToCall = $scope.updateUsrPass;
		var argsToPass = {idx:index, frmDt:formData};
		
		$rootScope.showGlbModal($rootScope.glbModalConf,
								"Saving usrpass '" + (formData.uid) +"'!!!",
								funcToCall,
								argsToPass);
	}
	
	
	$scope.onDeleteBtn = function(index)
	{
		var funcToCall = $scope.removeUsrPass;
		var argsToPass = {idx:index};
		
		$rootScope.showGlbModal($rootScope.glbModalConf,
								"Deleting usrpass '" + ($scope.usrpasses[index].uid) +"'!!!",
								funcToCall,
								argsToPass);
	}

	///////////////////////////////////////////////////////////////////////////////////////////////
	
    $scope.addUsrPass = function() {
      $scope.inserted = {iscrt: true, uid: '', usrname: '', usrtype: '', prdtype: '', status: '', balance:'', enabled:1, stvldty:"", edvldty:"", rawdata:'', pinnumb:'', pinattempts:0, maxattempts:0, reserved:0};
	  $scope.usrpasses.length + 1;
      $scope.usrpasses.splice(0,0,$scope.inserted);
	  $scope.deepview = true;
    };
	
	$scope.editUsrPass = function(rowform) {
	  rowform.$show(); 
	  $scope.deepview = true;
    };
	
	$scope.cancelUsrPass = function(rowform) {
	  if(angular.isUndefined($scope.inserted) == false){
		  $scope.usrpasses.splice(0, 1);
		  delete $scope.inserted;
	  }
	  rowform.$cancel();
    };
	
    editableOptions.theme = 'bs3';
    editableThemes['bs3'].submitTpl = '<button type="submit" class="btn btn-primary btn-with-icon"><i class="ion-checkmark-round"></i></button>';
    editableThemes['bs3'].cancelTpl = '<button type="button" ng-click="$form.$cancel()" class="btn btn-default btn-with-icon"><i class="ion-close-round"></i></button>';
  }

})();
