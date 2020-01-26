/**
 * @author v.lugovsky
 * created on 16.12.2015
 */
(function () {
  'use strict';

  angular.module('JPSAdmin.pages.administration.usrpasses', [])
      .config(routeConfig);

  /** @ngInject */
  function routeConfig($stateProvider) {
    $stateProvider
        .state('administration.usrpasses', {
          url: '/usrpasses',
          templateUrl: 'app/pages/administration/usrpasses/usrpasses.html',
          controller: 'UsrPassesPageCtrl',
          title: '_LFTBAR_ADMIN_USRPASS_',
          sidebarMeta: {
            order: 500,
			roles: ['Administrator']
          },
        });
  }

})();
