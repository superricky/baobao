angular.module('webstore.controllers.carts', []).
  controller('cartDetailController', ['$rootScope', '$scope', '$routeParams', 'cartService', 'branchService', 'memberService',
    function($rootScope, $scope, $routeParams, cartService, branchService, memberService) {
      branchService.get($routeParams.branch_id, function(branch){
        $scope.branch = branch;
        $scope.products = branchService.products();
        $scope.hots = branchService.hots();
        $scope.cart = cartService.cart(branch);
        $scope.notice = null;
        calculate();
      });

      function calculate(){
        $scope.products_in_cart = cartService.products($scope.branch, $scope.products);
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

      $scope.remove_from_cart = function(product){
        cartService.remove($scope.branch, product);
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

      $scope.clear_cart = function(){
        cartService.clear();
        calculate();
      }

      $scope.next_url = function(){
        var order_fill_in_path = ["#", "branches", $routeParams.branch_id, "order", "fill_in"].join("/");
        var login_path = "#/member/login";
        var url = login_path;
        $scope.notice = null;
        if(typeof($scope.branch) == "undefined" || $scope.branch.use_min_order_charge == false){
          url = order_fill_in_path;
        }else{
          if(cartService.charge($scope.branch, $scope.products) == true){
            url = order_fill_in_path;
          }else{
            $scope.notice = "您订购了少于起送价的货品！";
            url = "javascript:void(0);"
          }
        }

        if(!memberService.isAuthenticated()){
          url = login_path
        }
        return url;
      }
    }
  ]
);