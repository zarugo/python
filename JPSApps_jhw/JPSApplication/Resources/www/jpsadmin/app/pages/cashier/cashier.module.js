/**
 * @author v.lugovsky
 * created on 16.12.2015
 */
(function () {
  'use strict';

  //Create and Configure the .cashier module
  angular.module('JPSAdmin.pages.cashier', [])
      .config(routeConfig);

  /** @ngInject */
  //This is the configuration function that directly relys on the injected stateProvider object 
  //to configure the state service for the cashier view. It says "when the cashier state is
  //activated the "app/pages/cashier/cashier.html" template must be injected into the cashier's
  //parent ui-view:
  function routeConfig($stateProvider) {
    $stateProvider
        .state('cashier', {
          url: '/cashier',
          templateUrl: 'app/pages/cashier/cashier.html',
          title: '_LFTBAR_CASHIER_',
          sidebarMeta: {
            icon: 'ion-cash',
            order: 100,
			roles: ['Cashier','Administrator']
          }
        });
  }

})();
