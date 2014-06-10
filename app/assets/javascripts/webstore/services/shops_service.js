'use strict';

/* Services */


// Demonstrate how to register services
// In this case it is a simple value service.
angular.module('webstore.services.shops', ['ngResource']).
  service('shopService', ['$rootScope', '$resource', '$location', function($rootScope, $resource, $location){
  var Shop = $resource(baseURL+".json");

  var shop = undefined;

  function get(success){
    if(shop){
      success(shop);
    }else{
      Shop.get({}, function(resp){
        $rootScope.current_shop = resp;
        shop = resp;
        success(resp);
      });
    }
  };

  function redirect_to_branch(branches){
    if(branches.length == 1){
      var url = ["branches",branches[0].id].join("/");
      $location.path(url);
    }
  }

  return {
    get: get,
    redirect_to_branch: redirect_to_branch
  }
}]);