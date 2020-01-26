/**
 * @author v.lugovksy
 * created on 16.12.2015
 */
(function () {
  'use strict';

  //At a high level, directives are markers on a DOM element (such as an attribute, element name, comment or CSS class)
  //that tell AngularJS's HTML compiler ($compile) to attach a specified behavior to that DOM element (e.g. via event listeners),
  //or even to transform the DOM element and its children. Here we are declaring a directive for an html element "<cashier-bill-chart>"
  //son of the 'cashier' module:
  angular.module('JPSAdmin.pages.cashier')
      .directive('cashierFiscalPrinter', cashierFiscalPrinter);

  /** @ngInject */
  //Here we also specify to angular:
   function cashierFiscalPrinter() {
    return {
      restrict: 'E', //1) To only match directives based on their element name;
      controller: 'CashierFiscalPrinterCtrl', //2) To apply the controller CashierFiscalPrinterCtrl;
      templateUrl: 'app/pages/cashier/cashierFiscalPrinter/cashierFiscalPrinter.html' //3) To use as template cashierFiscalPrinter.html;
    };
  }
})();