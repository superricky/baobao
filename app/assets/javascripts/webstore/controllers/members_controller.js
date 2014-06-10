angular.module('webstore.controllers.members', []).
  controller('memberController', ['$rootScope', '$scope', '$routeParams', 'memberService',
    function($rootScope, $scope, $routeParams, memberService) {

      $scope.member =  $rootScope.currentMember||{};

      if($routeParams["events"] == "confirm_success"){
        $scope.authSuccess = "成功激活帐号，请登录";
      }

      $scope.$on("events:loadMember", function(){
        $scope.member = $rootScope.currentMember;
      });

      $scope.login = function(member){
        $scope.authError = null;
        $scope.authSuccess = null;
        memberService.login(member.email, member.password).then(function(response) {
            $scope.authSuccess = '恭喜您，登录成功';
        }, function(response) {
          $scope.authError = response.data.error||'服务器错误，请稍后重试...';
        });
      }

      $scope.register = function(member) {
        $scope.authError = null;

        memberService.register(member.name, member.email, member.password, member.password_confirmation)
          .then(function(response){
            $scope.authSuccess = '账户注册成功，请前往您的邮箱进行激活！';
            $scope.member = $scope.currentMember;
          }, function(response){
            if(response.data.errors){
              var errors = "";
              for(var key in response.data.errors){
                errors += key + response.data.errors[key] + '\n';
              }
              $scope.authError = errors;
            }
          });
       };

      $scope.submit = function(member){
        $scope.memberEditError = null;
        $scope.memberEditSuccess = null;
        memberService.update(member).then(function(response){
          $scope.memberEditSuccess = '更新账户信息成功完成';
        }, function(response){
          if(response.data.errors){
            var errors = response.data.errors.join(", ");
            $scope.memberEditError = errors;
          }
        });
      };

      $scope.change_password = function(member){
        $scope.memberChangePasswordError = null;
        $scope.memberChangePasswordSuccess = null;
        memberService.change_password(member).then(function(response){
          $scope.memberChangePasswordSuccess = '密码修改成功';
        }, function(response){
          if(response.data.errors){
            var errors = response.data.errors.join(", ");
            $scope.memberChangePasswordError = errors;
          }
        });
      };
  }]);