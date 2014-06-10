"use strict"

angular.module('webstore.controllers.branches', ["ngRoute"]).
  controller('branchController', ['$rootScope', '$scope', '$routeParams', '$anchorScroll', '$location', 'branchService', 'cartService',
    function($rootScope, $scope, $routeParams, $anchorScroll, $location, branchService, cartService) {

    branchService.get($routeParams.branch_id, function(branch){
      $scope.branch = branch;
      $scope.hots = branchService.hots();
      $scope.products = branchService.products();
      calculate();
    });

    function calculate(){
      $scope.count = cartService.count($scope.branch);
      $scope.total = cartService.total($scope.branch, $scope.products);
    }

    $scope.add_to_cart = function(product){
      if($scope.count_of_product(product.id) >= product.stock){
        alert("库存不够！");
        return;
      }
      cartService.set($scope.branch, product);
      calculate();
    }

    $scope.minus_from_cart = function(product){
      cartService.minus($scope.branch, product);
      calculate();
    }

    $scope.count_of_product = function(product){
      return cartService.quantity($scope.branch, product);
    }

    $scope.cart_show = function(){
      if(typeof($scope.branch)=="undefined"){
        return false;
      }
      return cartService.count($scope.branch) > 0
    }

    $scope.in_cart = function(product){
      var cart_item = cartService.cart_item($scope.branch, product);
      if(typeof(cart_item) == "undefined"){
        return false;
      }
      return true;
    }

    $scope.goto_anchor = function(category){
      var old = $location.hash();
      var hash = ["category_", category.id].join("");
      $location.hash(hash);
      $anchorScroll();
      $location.hash(old);
    }
  }]);
