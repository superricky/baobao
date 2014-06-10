"use strict"

angular.module('webstore.controllers.order', []).
  controller('orderController', ['$rootScope', '$scope', '$routeParams', '$location', 'orderService', 'cartService', 'branchService', 'memberService',
    function($rootScope, $scope, $routeParams, $location, orderService, cartService, branchService, memberService) {
      if(typeof(orderService.get())=="undefined"){
        history.back();
      }
      $scope.other_total = 0;
      $scope.order = orderService.get();
      branchService.get($routeParams.branch_id, function(branch){
        $scope.branch = branch;
        $scope.products = branchService.products();
        $scope.cart = cartService.cart(branch);
        $scope.member = $rootScope.currentMember;
        calculate();
      });

      function calculate(){
        $scope.products_in_cart = cartService.products($scope.branch, $scope.products);
        $scope.count = cartService.count($scope.branch);
        $scope.total = cartService.total($scope.branch, $scope.products);
      }

      $scope.count_of_product = function(product){
        return cartService.quantity($scope.branch, product);
      }

      $scope.order_types_view = function(type){
        var name = "";
        angular.forEach($scope.order_types, function(order_type){
          if(typeof(type) != "undefined"){
            if(order_type.value.toString() == type.toString()){
              name = order_type.name;
            }
          }
        });
        return name;
      }

      $scope.get_delievery_zone_name = function(){
        return orderService.getDelieveryZoneName($scope.branch, $scope.order.delivery_zone_id)
      }

      function set_order_items(member){
      }

      $scope.charge = function(){
        if(typeof($scope.branch) != "undefined" && typeof($scope.order) != "undefined"){
          $scope.zone = branchService.zone($scope.branch, $scope.order);
          if($scope.total < $scope.branch.min_order_charge){
            $scope.other_total = parseInt($scope.zone.charge,10)
          }
        }
        return true;
      }

      $scope.order_commit = function(){
        $scope.order = cartService.package_order_items($scope.branch, $scope.products, $scope.member, $scope.order);
        orderService.set($scope.branch, $scope.member, $scope.order);
        orderService.commit($scope.branch, $scope.member).success(function(){
          cartService.clear();
          orderService.clear();
          alert("订单提交成功！");
          $location.path(baseURL);
        }).error(function(message){
          alert(message.join("\n"));
        });
      }
    }
  ]
).controller('ordersController', ['$rootScope', '$scope', '$location', 'orderService',
    function($rootScope, $scope,  $location, orderService) {
        orderService.all(function(orders){
          $scope.orders = orders;
        });

        $scope.my_orders = function(){
          if(typeof($scope.orders)=="undefined"){
            return false;
          }
          return true;
        }
    }]);