'use strict';

var shop_slug = function(){
  if(location.host.split(".").length == 4){
    return location.host.split(".")[0]
  }else{
    return $('meta[name=shop_slug]').attr('content');
  }
};
var baseURL = "webstore/" + shop_slug();
var LOGIN_PATH = "/member/login"


// Declare app level module which depends on filters, and services
angular.module('webstore', [
  'ngRoute',
  'webstore.controllers.shops',
  'webstore.controllers.carts',
  'webstore.controllers.branches',
  'webstore.controllers.products',
  'webstore.controllers.members',
  'webstore.controllers.order',
  'webstore.controllers.order_fill_in',
  'webstore.services.shops',
  'webstore.services.carts',
  'webstore.services.branches',
  'webstore.services.products',
  'webstore.services.members',
  'webstore.services.orders',
  'webstore.filters',
  'ngCookies'
]).config(['$httpProvider', function($httpProvider){
      $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
      $httpProvider.defaults.useXDomain = true;
      var interceptor = ['$rootScope', '$q', function (scope, $q) {
      function success(response) {
          return response;
      }

      function error(response) {
        var status = response.status;
        if ((status == 401) && (window.location.hash.indexOf(LOGIN_PATH) == -1) && (window.location.hash.indexOf("orders") != -1 || window.location.hash.indexOf("member") != -1 || window.location.hash.indexOf("order") != -1)) {
            var deferred = $q.defer();
            var req = {
                config: response.config,
                deferred: deferred
            }
            //scope.requests401.push(req);
            scope.$broadcast('event:loginRequired');
            //AccountService.Logout();
            return deferred.promise;
        }
        // otherwise
        return $q.reject(response);
      }

      return function (promise) {
          return promise.then(success, error);
      }
    }];
    $httpProvider.responseInterceptors.push(interceptor);

   }]).
config(['$routeProvider', function($routeProvider) {
  $routeProvider
    .when('/', {templateUrl: 'webstore_partials/shop.html'})
    .when('/orders/index', {templateUrl: 'webstore_partials/orders/index.html'})
    .when(LOGIN_PATH, {templateUrl: 'webstore_partials/login.html'})
    .when('/member/show', {templateUrl: 'webstore_partials/member/show.html'})
    .when('/member/edit', {templateUrl: 'webstore_partials/member/edit.html'})
    .when('/member/change_password', {templateUrl: 'webstore_partials/member/change_password.html'})
    .when('/member/register', {templateUrl: 'webstore_partials/registration.html'})
    .when('/branches/:branch_id', {templateUrl: 'webstore_partials/branch.html'})
    .when('/branches/:branch_id/products/:product_id', {templateUrl: 'webstore_partials/product_detail.html'})
    .when('/branches/:branch_id/cart', {templateUrl: 'webstore_partials/cart_detail.html'})
    .when('/branches/:branch_id/order/fill_in', {templateUrl: 'webstore_partials/orders/order_fill_in.html'})
    .when('/branches/:branch_id/order/new', {templateUrl: 'webstore_partials/orders/order_new.html'})
    .otherwise({redirectTo: '/'});
}]).run(['$location', '$rootScope', '$routeParams','memberService',
              function($location, $rootScope, $routeParams, memberService){
    //$rootScope.requests401 = [];
    $rootScope.$on('$routeChangeSuccess', function(event, current, previous){
      if(current.$route != undefined){
        $rootScope.pageTitle = current.$route.title;
      }
    });
    $rootScope.$on('event:loginRequired', function(){
      $location.path(LOGIN_PATH);
    });

    $rootScope.logout = function(){
      memberService.logout();
    }

    memberService.get();
  }]);
