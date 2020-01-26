/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
  'use strict';

  angular.module('JPSAdmin.theme.components')
      .controller('LangListCtrl', LangListCtrl);

  /** @ngInject */
  function LangListCtrl($rootScope, $scope) {
	 
	$scope.langs = [];
	 
	$scope.getLangList = function () {
		return $rootScope.getLanguages();
	}
	
	////////////////////////////////////////// EXECUTE ACTION ////////////////////////////////////
	$scope.changeLanguage = function(key) {
		$rootScope.changeLanguage(key);
	};
	
	$scope.langs = $scope.getLangList();
  }
})();