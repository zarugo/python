$(document).ready(function() {
	$("#acoin-aed").alpaca({
		"dataSource": "./acoin/aed/cur.json",
		"schemaSource": "./acoin/ConfigSchema.json",
		"view":"bootstrap-edit-horizontal",
		"optionsSource": "./acoin/ConfigOptions.json",
		///////////////////////////////////////////////////////////////////////////// OPTIONS /////////////////////////////////////////////////////////////////
		"options": {
			"form":{
				"attributes":{
					"action":"/webcfgtool",
					"method":"post"
				},
				"buttons":{
					"validate":{
						"title": "Validate",
						"click": function() {
							var val = this.getValue();
							if (this.isValid(true)) {
								alert("The data model is valid!");
							} else {
								var errors = "";
								$(".alpaca-invalid").each(function(){
									errors = errors +";\n"+$(this).attr("data-alpaca-field-path");
								});
								alert("Invalid value in: " + errors);
							}
						}
					},
					"submit0":{
						"title": "Send Configuration",
						"click": function() {
							var val = this.getValue();
							if (this.isValid(true)) {
								var myjson= JSON.stringify(val, null, "  ");
								var blob = new Blob([myjson], {type: "application/json"});
								var filename = 'cur.json';
								var formData = new FormData();
								formData.append('file', new File([blob], filename));
								var request = new XMLHttpRequest();
								request.onreadystatechange = function() {if (request.readyState == XMLHttpRequest.DONE) {alert(request.responseText);}}
								request.open("POST", "/webcfgtool/currencies/acoin/aed");
								request.send(formData);
							} else {
								alert("Invalid value: " + JSON.stringify(val, null, "  "));
							}
						}
					}
				}
			}
		},
		"postRender": function(control) {
			setTimeout(delayedFadeOut, 500);
			$( ".help-block" ).each(function() {
				//Dump the <p>...</p> element:
				var html_dump = $(this).outerHTML();
				//Dump and remove its <i>...</i> element:
				html_dump = $(this).children("i:first").outerHTML();
				$(this).children("i:first").remove();
				//Dump the <p>...</p> element without the inner <i>...</i>:
				var html_dump = $(this).outerHTML();
				//Get the helper message:
				var helper_msg = this.innerHTML;
				var new_helper_node = '<span data-toggle="tooltip" data-placement="top" data-delay="{ show: 1, hide: 5000}" title="' + helper_msg + '" style="padding-left:20px"><i class="alpaca-icon-16 glyphicon glyphicon-info-sign"/></span>';
				$(this).parent().children("legend:first").append(new_helper_node);
				$(this).parent().children("label:first").append(new_helper_node);
				$(this).empty();
			});
		}
	});/*End Of $("#timings").alpaca({ */
});
