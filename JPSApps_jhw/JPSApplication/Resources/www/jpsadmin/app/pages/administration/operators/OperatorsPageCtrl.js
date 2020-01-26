/**
 * @author v.lugovsky
 * created on 16.12.2015
 */
(function () {
  'use strict';

  angular.module('JPSAdmin.pages.administration.operators')
	.constant("operatorsUrl", "/jpsadmin/api/operators")
    .controller('OperatorsPageCtrl', OperatorsPageCtrl);

  /** @ngInject */
  function OperatorsPageCtrl($rootScope, $scope, $filter,  $http, operatorsUrl, editableOptions, editableThemes) {

	$scope.operators=[];
	$scope.bkpoperators=[];

    $scope.roles = [ 'Maintainer', 'Cashier','Administrator'];

    $scope.showRole = function(operator) {
      if(operator.role && $scope.roles.length) {
        var selected = operator.role;
        return selected.length ? selected : 'Not set';
      }
	  else {
		  return 'Not set';
	  }
    };
	
	////////////////////////////////////////// CRUD IMPLEMENTATION ////////////////////////////////////
	
	////////////////////////////////////////// READ ALL OPERATORS ////////////////////////////////////
	$scope.readOperators = function()
	{
		$http.get(operatorsUrl, {withCredentials : true})
		.success(function (data) {
			$scope.operators = data;			
			$scope.bkpoperators = data;		
		})
		.error(function (error) {
			alert(error);
		});
	}
	//Always call to initialize the data:
	$scope.readOperators();
	//////////////////////////////////////////////////////////////////////////////////////////////
	
	////////////////////////////////////////// READ OPERATOR ////////////////////////////////////
	$scope.readOperator = function(index)
	{
		$http.get(operatorsUrl+'/'+$scope.operators[index].id, {withCredentials : true})
		.success(function (data) {
			$scope.operators[index] = data;
			$scope.bkpoperators[index] = data;
		})
		.error(function (error) {
			alert(error);
		});
	}
	//////////////////////////////////////////////////////////////////////////////////////////////	

	////////////////////////////////////////// CREATE/UPDATE OPERATOR ////////////////////////////////////
	$scope.updateOperator = function(callArgs) {
		var id = $scope.operators[callArgs.idx].id;
		
		var wtMsg = "Creating/Updating operator '" + (callArgs.frmDt.name) +"'";
		
		$scope.operators[callArgs.idx].id       = id;
		$scope.operators[callArgs.idx].name 	= callArgs.frmDt.name;
		$scope.operators[callArgs.idx].password = md5(callArgs.frmDt.password).toUpperCase();
		$scope.operators[callArgs.idx].role     = callArgs.frmDt.role;
		$scope.operators[callArgs.idx].stVldty  = $filter('date')(callArgs.frmDt.stVldty, "dd-MM-yyyyTHH:mm:ss");
		$scope.operators[callArgs.idx].edVldty  = $filter('date')(callArgs.frmDt.edVldty, "dd-MM-yyyyTHH:mm:ss");
		$scope.operators[callArgs.idx].enabled  = (callArgs.frmDt.enabled > 0) ? true :false;
		$scope.operators[callArgs.idx].sessTok  = "";
		
		$rootScope.showGlbModal($rootScope.glbModalWt, wtMsg, function(){}, {});
		
		if(id == 0)
		{
			$http.post(operatorsUrl+'/'+$scope.operators[callArgs.idx].id, $scope.operators[callArgs.idx],{withCredentials : true})
			.success(function (data) {
				$scope.operators[callArgs.idx] = data;
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
			$http.put(operatorsUrl+'/'+$scope.operators[callArgs.idx].id, $scope.operators[callArgs.idx], {withCredentials : true})
			.success(function (data) {
				$scope.operators[callArgs.idx] = data;
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
	
    ////////////////////////////////////////// DELETE OPERATOR ////////////////////////////////////
	$scope.removeOperator = function(callArgs) {
		var index = callArgs.idx;
		var wtMsg = "Deleting operator '" + ($scope.operators[index].name) +"'";
		
		$rootScope.showGlbModal($rootScope.glbModalWt, wtMsg, function(){}, {});
		
		$http.delete(operatorsUrl+'/'+$scope.operators[index].id, {withCredentials : true})
			.success(function (data) {
				$scope.operators.splice(index, 1);
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
		var funcToCall = $scope.updateOperator;
		var argsToPass = {idx:index, frmDt:formData};
		
		//funcToCall(argsToPass);
		
		$rootScope.showGlbModal($rootScope.glbModalConf,
								"Saving operator '" + (formData.name) +"'!!!",
								funcToCall,
								argsToPass);
	}
	
	
	$scope.onDeleteBtn = function(index)
	{
		var funcToCall = $scope.removeOperator;
		var argsToPass = {idx:index};
		
		//funcToCall(argsToPass);
		
		$rootScope.showGlbModal($rootScope.glbModalConf,
								"Deleting operator '" + ($scope.operators[index].name) +"'!!!",
								funcToCall,
								argsToPass);
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
    $scope.addOperator = function() {
      $scope.inserted = { id: 0, name: '', password: '', role: '', stVldty:"", edVldty:"", enabled:1, sessTok:''};
	  $scope.operators.length + 1;
      $scope.operators.splice(0,0,$scope.inserted);
    };
	
	$scope.cancelOperator = function(rowform) {
	  if(angular.isUndefined($scope.inserted) == false){
		  //$scope.operators.pop();
		  $scope.operators.splice(0, 1);
		  delete $scope.inserted;
	  }
	  rowform.$cancel();
    };
	
    editableOptions.theme = 'bs3';
    editableThemes['bs3'].submitTpl = '<button type="submit" class="btn btn-primary btn-with-icon"><i class="ion-checkmark-round"></i></button>';
    editableThemes['bs3'].cancelTpl = '<button type="button" ng-click="$form.$cancel()" class="btn btn-default btn-with-icon"><i class="ion-close-round"></i></button>';
  }

})();
