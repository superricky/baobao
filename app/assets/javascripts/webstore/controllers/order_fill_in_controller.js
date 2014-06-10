"use strict"

angular.module('webstore.controllers.order_fill_in', []).
  controller('orderFillInController', ['$rootScope', '$scope', '$routeParams', '$location', 'orderService', 'branchService', 'memberService', 'cartService', 'shopService',
    function($rootScope, $scope, $routeParams, $location, orderService, branchService, memberService, cartService, shopService) {
      if(cartService.is_empty_cart()){
        $location.path(baseURL);
        alert("购物车不能为空！");
        return;
      }
      $scope.order_types = orderService.types();
      $scope.order_guest_numbers = orderService.guest_numbers();
      $scope.validation_code = "";
      $scope.input_code_is_disabled = true;
      $scope.not_validated = true;
      $scope.order = orderService.get();

      shopService.get(function(res){
        $scope.shop = res;
      });
      branchService.get($routeParams.branch_id, function(branch){
        var member = $rootScope.currentMember;
        $scope.branch = branch;
        $scope.set_not_validated(member.phone);
        if(typeof(orderService.get()) == "undefined"){
          orderService.set(branch, member);
        }
        $scope.order = orderService.get();
      });

      $scope.need_select_delivery_zone = function(){
        if($scope.order){
          if($scope.order.order_type == "delivery" && $scope.branch.use_min_order_charge && $scope.branch.delivery_zones.length >= 1){
            if($scope.branch.delivery_zones.length == 1){
              $scope.order.delivery_zone_id = $scope.branch.delivery_zones[0].id
              return false;
            }else{
              return true;
            }
          }
        }
      }

      $scope.set_not_validated = function(phone){
        var member = $rootScope.currentMember;
        if(typeof($rootScope.current_shop) != "undefined" && typeof($scope.branch) != "undefined"){
          if($rootScope.current_shop.use_sms_validation==true && $scope.branch.use_sms_validation == true){
            $scope.not_validated = true;
            return false;
          }else{
            $scope.not_validated = false;
            return false
          }
        }
        if(typeof(member) == "undefined" || typeof(member.validated_phones) == "undefined"){
          $scope.not_validated = true;
          return false;
        }
        if(member.validated_phones.indexOf(phone) == -1){
          $scope.not_validated = true;
          return false;
        }
        $scope.not_validated = false;
      }

      $scope.send_phone_validation_code = function($event){
        $event.target.disabled = true;
        var sec = 60;
        var interval_id = setInterval(function(){
          $event.target.value = ["剩余", sec, "秒可再发送"].join("");
          if(sec <= 1){
            $event.target.disabled = false;
            $event.target.value = "获取手机验证码";
            clearInterval(interval_id);
          }
          sec -= 1;
        }, 1000);
        $scope.input_code_is_disabled = orderService.send_phone_validation_code($scope.branch, $scope.order);
      }

      $scope.is_disabled = function(){
        return $scope.not_validated;
      }

      $scope.do_validate_code = function(validation_code){
        if(orderService.validate_validation_code(validation_code)){
          orderService.do_validate_code($scope.branch, $scope.order, validation_code).success(function(message){
            $scope.input_code_is_disabled = true;
            $scope.not_validated = false;
            alert(message["message"]);
          }).error(function(message){
            alert(message["message"]);
          });
        }else{
          return;
        }
      }

      $scope.next_url = function(){
        var errors = orderService.validate_form($scope.branch);
        if(errors.length == 0){
          return ["#", "branches", $routeParams.branch_id, "order", "new"].join("/");
        }
        return "javascript:void(0);";
      }

      $scope.phone_validable = function(){
        if(typeof($scope.order) == "undefined"){
          return false;
        }
        if(typeof($rootScope.currentMember.validated_phones) == "undefined"){
          return false;
        }else if($rootScope.currentMember.validated_phones.indexOf($scope.order.phone) >= 0){
          $scope.not_validated = false;
        }
        return orderService.validate_phone($scope.order.phone);
      }

      $scope.can_next_to_order_new = function(){
        var errors = orderService.validate_form($scope.branch);
        if(errors.length == 0){
          orderService.set($scope.branch, $scope.member, $scope.order);
          return true;
        }
        alert(errors.join("\n"));
        return false;
      }
    }
  ]
);
