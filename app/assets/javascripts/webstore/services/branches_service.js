'use strict';

/* Services */


// Demonstrate how to register services
// In this case it is a simple value service.
angular.module('webstore.services.branches', ['ngResource']).
  service('branchService', ['$rootScope', '$resource', function($rootScope, $resource){
  var Branch = $resource(baseURL+"/branches/:branch_id.json");

  var branches = [];
  var branch_products = [];
  var hot_products = [];

  function find(branch_id){
    for(var i = 0 ; i < branches.length; i ++){
      var branch = branches[i];
      if(branch.id === branch_id){
        return branch;
      }
    }
    return undefined;
  }

  function product(id){
    var product = branch_products.find(function(p){
      return p.id == id;
    });
    return product;
  }

  function set(branch_item){
    for(var i = 0 ; i < branches.length; i ++){
      var branch = branches[i];
      if(branch.id === branch_item.id){
        branches[i]= branch_item;
        return;
      }
    }
    branches.push(branch_item);
  }

  function get(branch_id, success){
    var branch = find(branch_id);
    if(branch){
      setProducts(branch);
      setHots(branch);
      success(branch);
    }else{
      Branch.get({branch_id: branch_id}, function(branch){
        set(branch)
        setProducts(branch);
        setHots(branch);
        success(branch);
      }, function(){
        alert("网络异常，请稍候重试！");
      });
    }
  }

  function setProducts(branch){
    branch_products = [];
    if(typeof(branch.categories)!= "undefined" && !branch.categories.isEmpty()){
      angular.forEach(branch.categories, function(category){
        branch_products = branch_products.include(category.products);
      });
    }
  }

  function setHots(branch){
    hot_products = [];
    if(typeof(branch.hot_products_of_week) == "undefined"){
      return;
    }
    angular.forEach(branch.hot_products_of_week, function(hot){
      hot_products.add(product(hot.id));
    });
  }

  function getHots(){
    return hot_products;
  }

  function getProducts(){
    return branch_products;
  }

  function getZone(branch, order){
    return branch.delivery_zones.find(function(zone){
      return zone.id == order.delivery_zone_id;
    });
  }

  return {
    get: get,
    products: getProducts,
    hots: getHots,
    product: product,
    zone: getZone
  }
}]);