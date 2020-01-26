/**
 * @author v.lugovsky
 * created on 16.12.2015
 */
(function () {
  'use strict';

  //Create and Configure the .terminal module
  angular.module('JPSAdmin.pages.administration.terminal', [])
      .config(routeConfig);

  /** @ngInject */
  //This is the configuration function that directly relys on the injected stateProvider object 
  //to configure the state service for the terminal view. It says "when the terminal state is
  //activated the "app/pages/terminal/terminal.html" template must be injected into the terminal's
  //parent ui-view:
  function routeConfig($stateProvider) {
    $stateProvider
        .state('administration.terminal', {
          url: '/terminal',
          templateUrl: 'app/pages/administration/terminal/terminal.html',
          title: '_LFTBAR_ADMIN_TERM_',
          sidebarMeta: {
            order: 500,
			roles: ['Administrator']
          },
		  data: {
			requireLogin: true
		  }
        });
  }

})();
