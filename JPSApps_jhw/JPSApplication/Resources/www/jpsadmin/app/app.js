'use strict';

////////////////////////////////////////////// APP DECLARATION //////////////////////////////////////////////////////////////
//AngularJS apps are formed from one or more modules. Modules are created by calling the angular.module method,
//as follows: ...var todoApp = angular.module("JPSAdmin", []);...
//"JPSAdmin" => module name, [...] => dependency array (standard and user defined list) see https://docs.angularjs.org/api/
//Passing the 2nd parameter [...] the angular framework creates a new module called "JPSAdmin"
var app = angular.module('JPSAdmin', [
  //Standard/extern dependencies
  'ngAnimate',
  'ui.bootstrap',
  'ui.sortable',
  'ui.router',
  'ngTouch',
  'toastr',
  'smart-table',
  "xeditable",
  'ui.slimscroll',
  'ngJsTree',
  'angular-progress-button-styles',
  'ngCookies',		//For session management
  //Local app dependencies
  'JPSAdmin.theme', //See theme.module.js
  'JPSAdmin.pages',  //See pages.module.js
  'pascalprecht.translate'
]);

////////////////////////////////////////////// APP CONFIGURATION //////////////////////////////////////////////////////////////
app.config(function ($translateProvider) {
	var mainLang;
	
	for(const [key, value] of Object.entries(_LANGUAGES_)) {
		$translateProvider.translations(key, value);
		if(!mainLang){mainLang = key;}
	}
	
	$translateProvider.preferredLanguage(mainLang);
});

////////////////////////////////////////////// APP INITIALIZATION //////////////////////////////////////////////////////////////
app.run(function($rootScope, $cookies, $state, $translate){
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Retrieve operator info from session cookie:
	$rootScope.currOperator = {};
	$rootScope.currOperator.id = $cookies.get("id");
	$rootScope.currOperator.name = $cookies.get("name");
	$rootScope.currOperator.role = $cookies.get("role");
	$rootScope.currOperator.sessTok = $cookies.get("sessTok");
	$rootScope.periphClass = $cookies.get("periphclass");
	$rootScope.periphType = $cookies.get("periphtype");
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Collect language keys to be listed as clickable links:
	$rootScope.langs = [];	
	for(const [key, value] of Object.entries(_LANGUAGES_)) {
		$rootScope.langs.push(key);
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Initialize global modal popup to handle user actions (see the matching modal elements in index.html):	
	//1) The global modal action confirmation popup:
	$rootScope.glbModalConf = {
		id:"glbModalConf",
		call:{
			funct:function(){},
			args:{}
		},
		loc:"#"
	};
	
	//2) The global modal action wait popup:
	$rootScope.glbModalWt = {
		id:"glbModalWt",
		call:{
			funct:function(){},
			args:{}
		},
		loc:"#"
	};
	
	//3) The global modal action result popup:
	$rootScope.glbModalRes = {
		id:"glbModalRes",
		call:{
			funct:function(){},
			args:{}
		},
		loc:"#"
	};

	//The global function used to show one of the previously defined modal popup. This function takes a global
	//modal popup object (glbModObj), a message to be shown (msg), a function to be called on popup fade out (funct)
	//the arguments to be passed to the fade out function (args):
	$rootScope.showGlbModal = function(glbModObj, msg, funct, args)
	{
		glbModObj.call.funct = funct;
		glbModObj.call.args = args;
		var modalDiv = document.getElementById(glbModObj.id);
		var modalMsg = document.getElementById(glbModObj.id+'Msg');
		modalMsg.innerHTML = msg;

		///////////////////////////////////////////////////////////////////////////////////////		
		$("body").attr('class','modal-open');
		$(".modal-backdrop").css("display", "block");
		////////////////////////////////////////////////////////////////////////////////////////		

		modalDiv.className = "modal fade in";
	};
	
	//The global function used to hide one of the previously defined modal popup. This function takes a global
	//modal popup object (glbModObj) and a flag to enable/disable the fade out function call, if any (ret):
	$rootScope.hideGlbModal = function(glbModObj,ret)
	{
		var modalDiv = document.getElementById(glbModObj.id);
		
		////////////////////////////////////////////////////////////////////////////////////////
		$(".modal-backdrop").css("display", "none");
		$("body").attr('class','');
		////////////////////////////////////////////////////////////////////////////////////////
		
		modalDiv.className = "modal hide";
		if((ret == true) && (glbModObj.call.funct != null))
		{
			glbModObj.call.funct(glbModObj.call.args);
		}
	};
	
	$rootScope.changeLanguage = function (key)
	{
		$translate.use(key);
	};
	
	$rootScope.getLanguages = function ()
	{
		return $rootScope.langs;
	};

});

