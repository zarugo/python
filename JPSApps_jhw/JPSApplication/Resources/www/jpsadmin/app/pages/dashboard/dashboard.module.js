/**
 * @author v.lugovsky
 * created on 16.12.2015
 */
(function () {
  'use strict';

  //Create and Configure the .dashboard module
  angular.module('JPSAdmin.pages.dashboard', [])
      .config(routeConfig);

  /** @ngInject */
  //This is the configuration function that directly relys on the injected stateProvider object 
  //to configure the state service for the dashboard view. It says "when the dashboard state is
  //activated the "app/pages/dashboard/dashboard.html" template must be injected into the dashboard's
  //parent ui-view:
  function routeConfig($stateProvider) {
    $stateProvider
        .state('dashboard', {
          url: '/dashboard',
          templateUrl: 'app/pages/dashboard/dashboard.html',
          title: '_LFTBAR_DSHBRD_',
          sidebarMeta: {
            icon: 'ion-android-home',
            order: 0,
			roles: ['Cashier','Maintainer','Administrator']
          }
        });
  }

})();
