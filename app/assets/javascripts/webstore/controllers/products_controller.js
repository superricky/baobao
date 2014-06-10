angular.module('webstore.controllers.products', []).
  controller('productDetailController', ['$rootScope', '$scope', '$routeParams', '$sce', 'productService', 'branchService', 'cartService',
    function($rootScope, $scope, $routeParams, $sce, productService, branchService, cartService) {
    branchService.get($routeParams.branch_id, function(branch){
      $scope.hots = branchService.hots();
    });

    productService.get($routeParams.branch_id, $routeParams.product_id, function(resp){
      $scope.product = resp;
      $scope.product_description = $sce.trustAsHtml($scope.product.description);
    })

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

    $scope.in_cart = function(product){
      var cart_item = cartService.cart_item($scope.branch, product);
      if(typeof(cart_item) == "undefined"){
        return false;
      }
      return true;
    }
  }]);