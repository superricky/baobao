'use strict';

angular.module('webstore.services.members', ['ngResource']).
  service('memberService', ['$rootScope', '$http', '$location', function($rootScope, $http, $location){
    function login(email, password){
      return $http.post(baseURL+"/members/sign_in.json", {member:{email: email,shop_id: $('meta[name=shop_id]').attr('content'), password:password}})
        .then(function(response){
          $rootScope.currentMember = response.data.member;
          $rootScope.$broadcast("events:loadMember", response.data.member);
          if (isAuthenticated()) {
                $location.path('/');
            }
        });
    }

    function logout(){
      return $http({
              method: 'DELETE',
              url: baseURL+ '/members/signout.json'
           }).then(function(){
            $rootScope.currentMember = undefined;
            $location.path('/');
            alert("成功退出");
           });
    }

    function isAuthenticated(){
      return !!$rootScope.currentMember;
    }

    function register(name, email, password, password_confirmation){
       return $http.post(baseURL+"/members.json", {
          member: {
            name: name,
            email: email,
            shop_id: $('meta[name=shop_id]').attr('content'),
            password: password,
            password_confirmation: password_confirmation}
         })
       .then(function(response) {
            if (isAuthenticated()) {
                $location.path('/');
            }
        });
    }

    function get(){
      return $http.get(baseURL+"/member/show.json").then(function(response){
        $rootScope.currentMember = response.data;
        $rootScope.$broadcast("events:loadMember");
      });
    }

    function update(member){
      return $http.put(baseURL+"/member/update.json", {
        member: member
      }).then(function(response){
        $rootScope.currentMember = response.data;
        $rootScope.$broadcast("events:loadMember");
      });
    }



    function change_password(member){
      return $http.put(baseURL+"/members.json", {
        member: {
          current_password: member.current_password,
          password: member.password,
          password_confirmation: member.password_confirmation
        }
      }).then(function(response){
        $rootScope.currentMember = response.data;
        $rootScope.$broadcast("events:loadMember");
      });
    }

    return {
      login:login,
      isAuthenticated: isAuthenticated,
      register:register,
      logout: logout,
      get:get,
      update: update,
      change_password:change_password
    }
}]);