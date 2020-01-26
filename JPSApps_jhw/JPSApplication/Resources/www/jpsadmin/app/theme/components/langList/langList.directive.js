/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
  'use strict';

  angular.module('JPSAdmin.theme.components')
      .directive('langList', langList);

  /** @ngInject */
  function langList() {
    return {
      restrict: 'E',
      templateUrl: 'app/theme/components/langList/langList.html',
      controller: 'LangListCtrl'
    };
  }

})();