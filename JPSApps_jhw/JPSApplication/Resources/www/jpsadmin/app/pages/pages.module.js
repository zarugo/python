/**
 * @author v.lugovsky
 * created on 16.12.2015
 */
(function () {
  'use strict';

  
  angular.module('JPSAdmin.pages', [
    //Standard angular dependencies
	'ui.router',	
    //Local app dependencies
	'JPSAdmin.pages.dashboard',      //See dashboard.module.js
	'JPSAdmin.pages.cashier',  		 //See cashier.module.js
	'JPSAdmin.pages.administration'  //See administration.module.js
    //'JPSAdmin.pages.ui',
    //'JPSAdmin.pages.components',
    //'JPSAdmin.pages.form',
    //'JPSAdmin.pages.tables',
    //'JPSAdmin.pages.charts',
    //'JPSAdmin.pages.maps',
    //'JPSAdmin.pages.profile',
  ]).config(routeConfig);  //Configures this module to add specific behaviour, executed only the first time the angular is loaded:	

  /** @ngInject */
  //$... means => You need a dependency injection, angular will inject the right object based on id resource id      
  //It allows for different partial views to be displayed automatically based on the current URL
  function routeConfig($urlRouterProvider, baSidebarServiceProvider) {
	// When a state is activated, its templates are automatically inserted into the ui-view of its parent state's template.
	// If it's a top-level state—which 'dashboard' is because it has no parent state–then its parent template is index.html  
	// So any unmatched activates the dashboard state that is injected into the ui-view of the index.html template.
    $urlRouterProvider.otherwise('/dashboard');
	
	//There are different ways to create AngularJS services, and one of them creates a service that can be configured through a
	//provider object, whose name is the concatenation of the service name and Provider. Here we configure the baSidebarService 
	//adding all static sidebar items throught its Provider:
	//baSidebarServiceProvider.addStaticItem({
    //  title: 'Configurations',
    //  icon: 'ion-gear-a',
	//  fixedHref: './app/pages/webcfgtool/jpsdemoluatc/Config.html',
    //  blank: false
    //});
  }

})();
