/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
	'use strict';

	angular.module('JPSAdmin.pages.administration.setup')
	  .constant("pathsBySetupId", [
				{setupId:"Env"  , paths:["/webcfgtool/envctxt/ConfigSchema.json" ,"/webcfgtool/envctxt/ConfigData.json"          ,"/jpsadmin/api/setup/envctxt" ,""                              ,"envsetup_holder"], uncollapse:["envcroot"]                      ,watched:[]},
				{setupId:"Entry", paths:["/webcfgtool/leapp/ConfigSchema.json"   ,"/webcfgtool/leapp/LeApp/ConfigData.json"      ,"/jpsadmin/api/setup/jpsapp"  ,"/jpsadmin/api/setup/ckjpsapp"  ,"appsetup_holder"], uncollapse:["appcroot", "root-application"]  ,watched:[{field:"root.application.currency", notifyurl:"/jpsadmin/api/setup/currencies/"}]},
				{setupId:"Pay"  , paths:["/webcfgtool/apsapp/ConfigSchema.json"  ,"/webcfgtool/apsapp/ApsApp/ConfigData.json"    ,"/jpsadmin/api/setup/jpsapp"  ,"/jpsadmin/api/setup/ckjpsapp"  ,"appsetup_holder"], uncollapse:["appcroot", "root-application"]  ,watched:[{field:"root.application.currency", notifyurl:"/jpsadmin/api/setup/currencies/"}]},
				{setupId:"Exit" , paths:["/webcfgtool/aplapp/ConfigSchema.json"  ,"/webcfgtool/aplapp/AplApp/ConfigData.json"    ,"/jpsadmin/api/setup/jpsapp"  ,"/jpsadmin/api/setup/ckjpsapp"  ,"appsetup_holder"], uncollapse:["appcroot", "root-application"]  ,watched:[{field:"root.application.currency", notifyurl:"/jpsadmin/api/setup/currencies/"}]},
				{setupId:"Osc"  , paths:["/webcfgtool/outsched/ConfigSchema.json","/webcfgtool/outsched/OutSched/ConfigData.json","/jpsadmin/api/setup/outsched",""                              ,"oscsetup_holder"], uncollapse:["osccroot", "root-outscdservice"],watched:[]                                                                                }
				])
	.controller('SetupFormCtrl', SetupFormCtrl);

	/** @ngInject */
	function SetupFormCtrl($scope,$rootScope,pathsBySetupId) {
		
		////////////////////////// STATIC JSON Editor Configuration ////////////////////////////////////
		JSONEditor.defaults.options.theme = 'bootstrap3';
		JSONEditor.defaults.options.iconlib = "bootstrap3";
		JSONEditor.defaults.options.disable_edit_json = true;
		JSONEditor.defaults.options.disable_properties = true;
		JSONEditor.defaults.options.disable_array_add = false;
		JSONEditor.defaults.options.disable_array_delete = false;
		JSONEditor.defaults.options.disable_array_reorder = false;
		JSONEditor.defaults.options.no_additional_properties = true;
		JSONEditor.defaults.options.prompt_before_delete = true;
		JSONEditor.defaults.editors.object.options.collapsed = true;
		
		////////////////////////// ENV/APP/OSC Setup Editor Creation ////////////////////////////////////
		$scope.envSetupEditor = {};
		$scope.appSetupEditor = {};
		$scope.oscSetupEditor = {};
		
		////////////////////////// Generic Setup Editor Builder ////////////////////////////////////
		$scope.buildsSetupEditor = function (setupEditor, periphClass, ctrlPathsBySetupId, chainedBuilderFunc){
			
			setupEditor.periphClass = periphClass;
			
			for(var i=0;i<ctrlPathsBySetupId.length; ++i) {
				if(periphClass == ctrlPathsBySetupId[i].setupId)
				{
					setupEditor.schemaUrl   = ctrlPathsBySetupId[i].paths[0];
					setupEditor.dataUrl     = ctrlPathsBySetupId[i].paths[1];
					setupEditor.submitUrl   = ctrlPathsBySetupId[i].paths[2];
					setupEditor.validateUrl = ctrlPathsBySetupId[i].paths[3];
					setupEditor.holder      = ctrlPathsBySetupId[i].paths[4];
					setupEditor.uncollapse  = ctrlPathsBySetupId[i].uncollapse;
					setupEditor.watched    = ctrlPathsBySetupId[i].watched;
					setupEditor.watcherClbk = $scope.onWatchedUpdate;
					break;
				}
			}

			///////////////////////// Appplication Setup Editor Construction ///////////////////////////
			$rootScope.showGlbModal($rootScope.glbModalWt, "", function(){}, {});
			
			if (typeof setupEditor.editor !== "undefined") { setupEditor.editor.destroy(); }

			$.getJSON( setupEditor.schemaUrl, function( schema ) {
				
					setupEditor.schema = schema;
					
					$.getJSON( setupEditor.dataUrl, function( data ) {
					
						setupEditor.data = data;

						//1) Initialize the appsetup_editor with a JSON schema and data
						setupEditor.editor = new JSONEditor(document.getElementById(setupEditor.holder),{
							schema: setupEditor.schema,
							startval: setupEditor.data
						});

						//2) Force uncollapse for the outer editor element:
						setupEditor.uncollapse.forEach(function(item) { $("#"+item).attr("style","padding-bottom: 0px;"); });						
						$("#"+setupEditor.uncollapse[0]).css({ transform: 'scale(.98)' });						
						setupEditor.success = true;
						
						//3) Configure fields watchers:
						setupEditor.watched.forEach(function(watched){
							setupEditor.editor.watch(watched.field, setupEditor.watcherClbk.bind(setupEditor, watched));
						});						
						
						//4)Force a UI refresh
						$scope.$apply();
						
						//5.1)Call chained builders if available
						if(chainedBuilderFunc != null){ chainedBuilderFunc();}
						//5.2)Hides modal 'wait' if the builders chain ends within this call:
						else                          { $rootScope.hideGlbModal($rootScope.glbModalWt, false); }

					}).fail(function(){ setupEditor.error = "Error loading the form data"; $rootScope.hideGlbModal($rootScope.glbModalWt, false); });
			}).fail(function() { setupEditor.error = "Error loading the form schema";  $rootScope.hideGlbModal($rootScope.glbModalWt, false); });
		}
		
		
		////////////////////////////////////// UI ACTION FLOW MANAGEMENT ////////////////////////////////////
		////////////////////////// Submit Action Function ////////////////////////////////////
		$scope.execSubmit = function (callArgs) {
			
			var stpEdtr = callArgs.editor;
			var val = stpEdtr.editor.getValue();
			var errors = stpEdtr.editor.validate();
			
			if (errors.length){
				callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, errors, function(){}, {});
			}
			else {
				callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalWt, "", function(){}, {});
				var myjson= JSON.stringify(val, null, "  ");
				var blob = new Blob([myjson], {type: "application/json"});
				var filename = 'ConfigData.json.def';
				var formData = new FormData();
				formData.append('file', new File([blob], filename, {type:"text/plain;charset=unicode"}),);
				var request = new XMLHttpRequest();
				request.onreadystatechange = function()
				{
					if (request.readyState == XMLHttpRequest.DONE)
					{
						callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
						if (request.status == 200) {callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, request.response, function(){}, {});}
						else                       {callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, "Network Error: code " + request.status + ", "+request.data, function(){}, {});}
					}
				}
				request.open("POST", stpEdtr.submitUrl);
				request.setRequestHeader("periphclass",stpEdtr.periphClass);
				request.send(formData);
			}
			
		}
		
		////////////////////////// Validation Action Function ////////////////////////////////////
		$scope.execValidation = function (callArgs) {
			
			var stpEdtr = callArgs.editor;
			var val = stpEdtr.editor.getValue();
			var errors = stpEdtr.editor.validate();
			
			if (errors.length){
			
				var msg = "<div><center><font size='4'><b>Validation Error Details</b></font></center></div><div></div>"
				var tab = "<table class='table table-bordered table-hover table-condensed'><tr style='text-align: left'><td style='text-align: left'><b>Parameter</b></td><td><b>Value</b></td></tr>";
					
				errors.forEach(function(item){
					for(const [key, value] of Object.entries(item)) {
						tab = tab + "<tr><td style='text-align: left'><b>" + key  + "</b></td><td><b>" + value + "</b></td></tr>";
					}
				})
				tab = tab + "</table>";
				msg = msg + tab;
				
				callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, msg, function(){}, {});
			}
			else {
				if(stpEdtr.validateUrl.length == 0){callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, "Succeded", function(){}, {});}
				else
				{
					callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalWt, "", function(){}, {});
					var myjson= JSON.stringify(val, null, "  ");
					var blob = new Blob([myjson], {type: "application/json"});
					var filename = 'ConfigData.json.ck';
					var formData = new FormData();
					formData.append('file', new File([blob], filename, {type:"text/plain;charset=unicode"}),);
					var request = new XMLHttpRequest();
					request.onreadystatechange = function()
					{
						if (request.readyState == XMLHttpRequest.DONE)
						{
							callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
							if (request.status == 200) {callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, request.response, function(){}, {});}
							else                       {callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, "Network Error: code " + request.status + ", "+request.data, function(){}, {});}
						}
					}
					request.open("POST", stpEdtr.validateUrl);
					request.setRequestHeader("periphclass",stpEdtr.periphClass);
					request.send(formData);
				}
			}			
		}
		
		////////////////////////// Wached Action Function ////////////////////////////////////
		$scope.execWatchedUpdate = function (callArgs) {
			
			var stpEdtr  = callArgs.editor;
			var watched  = callArgs.watched;
			var newValue  = callArgs.newValue;
			
			callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalWt, "", function(){}, {});
			
			var request = new XMLHttpRequest();
			request.onreadystatechange = function()
			{
				if (request.readyState == XMLHttpRequest.DONE)
				{
					if (request.status == 200)
					{
						$scope.buildsSetupEditor(stpEdtr,$rootScope.periphClass,pathsBySetupId,null);
					}
					else
					{
						callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
						callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, "Network Error: code " + request.status + ", "+request.data, function(){}, {});
					}
				}
			}
			request.open("POST", callArgs.watched.notifyurl+newValue);
			request.setRequestHeader("periphclass",stpEdtr.periphClass);
			request.send();
		}
		
		////////////////////////// Wached Action Function ////////////////////////////////////
		$scope.execAlignMsTz = function (callArgs) {
			
			var stpEdtr  = callArgs.editor;
			
			
			callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalWt, "", function(){}, {});
			
			$.jrpc("/jpsadmin/api/cmd",
				   "mtz",
					[],
					function (data) {
						
						if (data.error) {
							callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
							if (data.error.error && data.error.error.message) {
								callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, "Error: " + data.error.error.message, function(){}, {});
							} else if (data.error.message) {
								callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, "Error: " + data.error.message, function(){}, {});
							} else {
								callArgs.rootScope.showGlbModal(callArgs.rootScope.glbModalRes, "Unknow JRPC Error: " + data, function(){}, {});
							}
						} else {
							var timezone = stpEdtr.editor.getEditor('root.timezone');
							timezone.setValue(data.result[0]);
							callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);
						}
					},
					function (xhr, status, error) {
						callArgs.rootScope.hideGlbModal(callArgs.rootScope.glbModalWt, false);							
						alert('[AJAX] ' + status + ' - Server reponse is: \n' + xhr.responseText);
					});
		}
		
		////////////////////////// Submit Button Callback ////////////////////////////////////
		$scope.onSetupSubmit = function(stpEdtr) {
			var msg = "Submitting setup.<br><br>(N.B. the software will be rebooted)</center>";
			var funcToCall = $scope.execSubmit;
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  editor:stpEdtr};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};
			
		////////////////////////// Validate Button Callback ////////////////////////////////////
		$scope.onSetupValidate = function(stpEdtr) {
			var msg = "Validating setup.";
			var funcToCall = $scope.execValidation;
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  editor:stpEdtr};
			
			$rootScope.showGlbModal($rootScope.glbModalConf,
			                        msg,
									funcToCall,
									argsToPass);
		};
		
		////////////////////////// Watched Field Callback ////////////////////////////////////
		$scope.onWatchedUpdate = function(watched) {
			console.log("field with path: [" + watched.field + "] changed to [" + JSON.stringify(this.editor.getEditor(watched.field).getValue()) + "]");
			var stpEdtr = this;
			var newValue = stpEdtr.editor.getEditor(watched.field).getValue();		
			
			var msg = "<center>Would you apply all default context for '"+newValue+"'?<br><br>(N.B. the current configuration will be overwritten)</center>";
			var funcToCall = $scope.execWatchedUpdate;
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  editor:stpEdtr,
							  watched:watched,
							  newValue:newValue};
			
			funcToCall(argsToPass);
		};
				
		////////////////////////// Watched Field Callback ////////////////////////////////////
		$scope.onAlignMsTz = function(stpEdtr) {
			var msg = "Align To MS Timnezone.";
			var funcToCall = $scope.execAlignMsTz;
			var argsToPass = {rootScope:$rootScope,
							  ctrlScope:$scope,
							  editor:stpEdtr};
			
			funcToCall(argsToPass);
		};
		
		////////////////////////// ENV Setup Editor Bulder ////////////////////////////////////
		$scope.buildsEnvSetupEditor = function (ctrlScope, periphClass, ctrlPathsBySetupId, chainedBuilderFunc){
			$scope.buildsSetupEditor(ctrlScope.envSetupEditor, periphClass, ctrlPathsBySetupId, chainedBuilderFunc);
		};

		////////////////////////// APP Setup Editor Bulder ////////////////////////////////////
		$scope.buildsAppSetupEditor = function (ctrlScope, periphClass, ctrlPathsBySetupId, chainedBuilderFunc){
			$scope.buildsSetupEditor(ctrlScope.appSetupEditor, periphClass, ctrlPathsBySetupId, chainedBuilderFunc);
		};
		
		////////////////////////// OSC Setup Editor Bulder ////////////////////////////////////
		$scope.buildsOscSetupEditor = function (ctrlScope, periphClass, ctrlPathsBySetupId, chainedBuilderFunc){
			$scope.buildsSetupEditor(ctrlScope.oscSetupEditor, periphClass, ctrlPathsBySetupId, chainedBuilderFunc);
		};
		
		$scope.refreshSetupEditors = function() {
			///////////////////////// Environment Setup Editor Construction ///////////////////////////
			$scope.buildsEnvSetupEditor($scope,"Env",pathsBySetupId,function(){
				///////////////////////// Application Setup Editor Construction ///////////////////////////
				$scope.buildsAppSetupEditor($scope,$rootScope.periphClass,pathsBySetupId,function(){
					///////////////////////// Output Scheduler Setup Editor Construction ///////////////////////////
					$scope.buildsOscSetupEditor($scope,"Osc",pathsBySetupId, null);
				});
			});
		};

		////////////////////////// RUNTIME BUILDER CODE ////////////////////////////////////		
	    jQuery(document).ready($scope.refreshSetupEditors);
	}
})();