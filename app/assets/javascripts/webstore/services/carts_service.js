'use strict';

angular.module('webstore.services.carts', ['ngResource']).
  service('cartService', ['$rootScope', '$resource', '$cookieStore', '$filter', function($rootScope, $resource, $cookieStore, $filter){

    //cart item structure
    //{
    //  product_id: product_id
    //  quantity: quantity
    //}

    //cart structure
    // {
    //   branch_id: branch_id
    //   cart_items: [cart_item...]
    // }

  var carts = [];

  function empty(obj){
    return typeof(obj) == "undefined" || obj == null;
  }

  function get(){
    if(empty($cookieStore.get('carts')) == false){
      return $cookieStore.get('carts');
    }
    return [];
  }

  function set(branch, product, success){
    $cookieStore.put('carts', eachCarts(get(), branch, product));
  }

  function clear(){
    $cookieStore.put('carts', []);
  }

  function is_empty_cart(){
    return get().length == 0;
  }

  function removeProduct(branch, product){
    var carts = get();
    angular.forEach(carts, function(cart, index){
      if(cart.branch_id == branch.id){
        angular.forEach(cart.cart_items, function(cart_item, idx){
          if(cart_item.product_id == product.id){
            carts[index].cart_items.removeAt(idx);
            return false;
          }
        });
      }
    });
    $cookieStore.put('carts', carts);
  }

  function minusProduct(branch, product){
    var carts = get();
    angular.forEach(carts, function(cart, index){
      if(cart.branch_id == branch.id){
        angular.forEach(cart.cart_items, function(cart_item, idx){
          if(cart_item.product_id == product.id){
            if(cart_item.quantity > 1){
              carts[index].cart_items[idx].quantity -= 1;
              return false;
            }
            carts[index].cart_items.removeAt(idx);
            return false;
          }
        });
      }
    });

    $cookieStore.put('carts', carts);
  }

  function getCart(branch, success){
    var obj = undefined;
    angular.forEach(get(), function(cart){
      if(cart.branch_id == branch.id){
        obj = cart
        return false;
      }
    });
    return obj;
  };

  function getCartItem(branch, product){
    var obj = undefined;
    var cart = getCart(branch);
    if(empty(cart) == true){
      return obj;
    }
    angular.forEach(cart.cart_items, function(item){
      if(item.product_id == product.id){
        obj = item;
        return false;
      }
    });
    return obj;
  }

  function quantity(branch, product){
    var item = getCartItem(branch, product);
    if(empty(item) == true){
      return 0;
    }else{
      return item.quantity;
    }
  }

  function eachCarts(carts, branch, product){
    var exist = false;
    angular.forEach(carts, function(cart, index){
      if(cart.branch_id == branch.id){
        carts[index].cart_items = eachCartItems(cart.cart_items, product);
        exist = true;
        return false;
      }
    });
    if(exist== true){
      return carts;
    }
    carts.add({branch_id: branch.id, cart_items: eachCartItems([], product)});
    return carts;
  }

  function eachCartItems(items, product){
    var exist = false;
    angular.forEach(items, function(item, index){
      if(item.product_id == product.id){
        items[index].quantity += 1;
        exist = true;
        return false;
      }
    });
    if(exist == true){
      return items;
    }
    items.add({product_id: product.id, quantity: 1});
    return items;
  }

  function total(branch, products){
    var t = 0;
    var pids = [];
    angular.forEach(products_uniq(products), function(product){
      var q = quantity(branch, product);
      t += q*product.price;
    });
    return t;
  }

  function products_uniq(products){
    return products.unique(function(obj){
      return obj.id;
    });
  }

  function count(branch){
    var cart = getCart(branch);
    if(empty(cart) == true || empty(cart.cart_items) == true){
      return 0;
    }
    var c = 0;
    angular.forEach(cart.cart_items, function(cart_item, index){
      c += cart_item.quantity;
    });
    return c;
  }

  function products_in_cart(branch, products){
    var cart = getCart(branch);
    if(typeof(cart) == "undefined"){
      return [];
    }
    var products_box = []
    angular.forEach(cart.cart_items, function(cart_item){
      var product = products_uniq(products).find(function(p){
        return p.id == cart_item.product_id;
      });
      if(empty(product) == false){
        products_box.add(product);
      }
    });
    return products_box;
  }

  function package_order_items(branch, products, member, order){
    order.order_items_attributes = {};
    angular.forEach(products_in_cart(branch, products), function(product, index){
      order.order_items_attributes[index]={name: product.name, price: product.price, quantity: quantity(branch, product), product_unit: product.product_unit, product_id: product.id};
    });
    return order;
  }

  function delivery_charges_less_than(branch, products){
    if(total(branch, products) >= branch.non_service_order_charge){
      return true;
    }
    return false;
  }

  return {
    get:get,
    set:set,
    cart_item: getCartItem,
    is_empty_cart: is_empty_cart,
    cart: getCart,
    quantity: quantity,
    minus: minusProduct,
    remove: removeProduct,
    count: count,
    total: total,
    clear: clear,
    products: products_in_cart,
    package_order_items: package_order_items,
    charge: delivery_charges_less_than
  }
}]);