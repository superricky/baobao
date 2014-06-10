"use strict"

angular.module('webstore.controllers.shops', []).
  controller('shopController', ['$rootScope', '$scope', 'shopService', function($rootScope, $scope, shopService) {
    shopService.get(function(resp){
      $scope.shop = resp;
      shopService.redirect_to_branch($scope.shop.branches);
    });
  }]);