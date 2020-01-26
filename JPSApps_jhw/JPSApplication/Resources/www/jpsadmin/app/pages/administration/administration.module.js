/**
 * @author v.lugovsky
 * created on 16.12.2015
 */
(function () {
  'use strict';

  angular.module('JPSAdmin.pages.administration', [
	'JPSAdmin.pages.administration.terminal',
    'JPSAdmin.pages.administration.operators',
    'JPSAdmin.pages.administration.usrpasses',
    'JPSAdmin.pages.administration.setup'
  ])
    .config(routeConfig);

  /** @ngInject */
  function routeConfig($stateProvider) {
    $stateProvider.state('administration',
		{
          url: '/administration',
          template : '<ui-view  autoscroll="true" autoscroll-body-top></ui-view>',
          abstract: true,
          title: '_LFTBAR_ADMIN_',
          sidebarMeta: {
            icon: 'ion-grid',
            order: 100,
			roles: ['Administrator']
          },
        });
  }
})();
