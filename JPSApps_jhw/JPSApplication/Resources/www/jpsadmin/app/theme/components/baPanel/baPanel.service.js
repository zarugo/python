/**
 * @author v.lugovsky
 * created on 23.12.2015
 */
(function () {
  'use strict';

  angular.module('JPSAdmin.theme')
      .factory('baPanel', baPanel);

  /** @ngInject */
  function baPanel() {

    /** Base baPanel directive */
    return {
      restrict: 'A',
      transclude: true,
      template: function(elem, attrs) {
		var headingTpl = '';
		var titleTpl = '';
        var res = '<div class="panel-body" ng-transclude></div>';
		
		if (attrs.baPanelTitle) {
			var trimmedTitle = attrs.baPanelTitle;
			var splitted = trimmedTitle.split(' ');
			var joined = splitted.join('');
			
  		    headingTpl = '<div class="panel-heading clearfix">';

			if (attrs.baPanelIco) {
			  titleTpl =  '<style>.ico' + joined + '{content: url("' + attrs.baPanelIco + '"); center repeat rgba(0, 0, 0, 0);padding: 5px 5px 5px 5px; height: 32px; width: 32px;}</style>';
			  titleTpl =  titleTpl + '<div style="display: flex;"><div><i class="ico' + joined + '"></i></div><div style="padding-top: 10px;">' + attrs.baPanelTitle + '</div></div>';
			}
			else {
			  titleTpl = titleTpl + '<h3 class="panel-title">' + attrs.baPanelTitle + '</h3>';
			}
			
			headingTpl = headingTpl + titleTpl + '</div>';
		}

		res = headingTpl + res; // title should be before
		//alert("DBG:"+res);
        return res;
      }
    };
  }

})();
