/**
 * @author v.lugovsky
 * created on 16.12.2015
 */
(function () {
  'use strict';

  angular.module('JPSAdmin.pages.administration.operators', [])
      .config(routeConfig);

  /** @ngInject */
  function routeConfig($stateProvider) {
    $stateProvider
        .state('administration.operators', {
          url: '/operators',
          templateUrl: 'app/pages/administration/operators/operators.html',
          controller: 'OperatorsPageCtrl',
          title: '_LFTBAR_ADMIN_OPRTRS_',
          sidebarMeta: {
            order: 500,
			roles: ['Administrator']
          },
        });
  }

})();
