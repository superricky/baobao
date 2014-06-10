'use strict';

/* Services */


// Demonstrate how to register services
// In this case it is a simple value service.
angular.module('webstore.services.products', ['ngResource']).
  service('productService', ['$rootScope', '$resource', '$http', function($rootScope, $resource, $http){
  var Product = $resource(baseURL+"/branches/:branch_id/products/:product_id.json");
  $http.defaults.useXDomain = true;
  /*
  function get(branch_id, product_id, success){
    Product.get({branch_id: branch_id, product_id: product_id}, function(product){
      success(product);
    });
  };*/
  function get(branch_id, product_id, success){
    var url = [baseURL, "branches", branch_id, "products", product_id+".json"].join("/");
    $http.get(url).success(function(product){
      success(product);
    });
  };

  return {
    get:get
  }

}]);