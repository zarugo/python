/**
 * @author v.lugovsky
 * created on 16.12.2015
 */
(function () {
  'use strict';

  //Create and Configure the .setup module
  angular.module('JPSAdmin.pages.administration.setup', [])
      .config(routeConfig);

  /** @ngInject */
  //This is the configuration function that directly relys on the injected stateProvider object 
  //to configure the state service for the setup view. It says "when the setup state is
  //activated the "app/pages/setup/setup.html" template must be injected into the setup's
  //parent ui-view:
  function routeConfig($stateProvider) {
    $stateProvider
        .state('administration.setup', {
          url: '/setup',
          templateUrl: 'app/pages/administration/setup/setup.html',
          title: '_LFTBAR_ADMIN_SETUP_',
          sidebarMeta: {
            icon: 'ion-gear-a',
            order: 100,
			roles: ['Administrator']
          },
		  data: {
			requireLogin: true
		  }
        });
  }

})();
