/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
  'use strict';

  //At a high level, directives are markers on a DOM element (such as an attribute, element name, comment or CSS class)
  //that tell AngularJS's HTML compiler ($compile) to attach a specified behavior to that DOM element (e.g. via event listeners),
  //or even to transform the DOM element and its children. Here we are declaring a directive for an html element "<cashier-ctrl-coard>"
  //son of the 'cashier' module:
  angular.module('JPSAdmin.pages.cashier')
      .directive('cashierCtrlBoard', cashierCtrlBoard);

  /** @ngInject */
  //Here we also specify to angular:
   function cashierCtrlBoard() {
    return {
      restrict: 'E', //1) To only match directives based on their element name;
      controller: 'CashierCtrlBoardCtrl', //2) To apply the controller CashierCtrlBoardCtrl;
      templateUrl: 'app/pages/cashier/cashierCtrlBoard/cashierCtrlBoard.html' //3) To use as template cashierCtrlBoard.html;
    };
  }
})();