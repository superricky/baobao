'use strict';

angular.module('webstore.services.orders', ['ngResource']).
  service('orderService', ['$rootScope', '$resource', '$http', function($rootScope, $resource, $http){
    var order = undefined;

    function types(){
      return [{name: "外送", value: "delivery"}, {name: "堂吃", value: "eat_in_hall"}, {name: "预订", value: "order_seat"}];
    }

    function guest_numbers(){
      return [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25];
    }

    function validate_phone(phone){
      return (phone||"").toString().match(/^((0?(13[0-9]|15[012356789]|18[012356789]|14[57])[0-9]{8})|(0\d{9}))$/i) != null;
    }

    function validate_validation_code(code){
      return (code||"").toString().match(/^\d{6}$/) != null;
    }

    function validate_presence(obj){
      if(typeof(obj) == "undefined"){
        return false;
      }
      if(obj == null){
        return false;
      }
      if(obj.toString().match(/^\S+$/) == null){
        return false;
      }
      return true;
    }

    function validate_form(branch){
      var errors = [];
      if(typeof(order) == "undefined"){
        return errors;
      }
      if(!validate_presence(order.name)){
        errors.add("姓名不能为空！");
      }

      if(!validate_presence(order.phone)){
        errors.add("手机不能为空！");
      }

      if(!validate_presence(order.delivery_zone_id) && order.use_min_order_charge){
        errors.add("请选择配送区域！");
      }

      if(order.order_type == "delivery" && branch.fixed_delivery_time && !order.delivery_period){
        errors.add("没有选择配送时间或不在商户的服务时间内!");
      }

      if(!validate_presence(order.address)){
        errors.add("配送地址不能为空！");
      }

      if(order.order_type != "delivery"){
        if(!validate_presence(order.guest_num)){
          errors.add("就餐人数请选择！");
        }
        if(!validate_presence(order.desk_no)){
          errors.add("桌号不能为空");
        }
      }

      if(typeof(branch) != "undefined"){
        angular.forEach(branch.form_elements, function(element, index){
          var content = order.form_contents_attributes[index].content;
          if(element["need"] == true && !validate_presence(content)){
            errors.add(element["label"]+"填写数据有误，请检查是否填写完整！");
          }else if(element["need"] == true && validate_presence(element["regex"]) && !validate_presence(content)){
            errors.add(element["label"]+"填写数据有误，请检查是否填写完整！");
          }
          if(validate_presence(element["need"]) == false && validate_presence(element["regex"]) && typeof(content) == "undefined"){
            errors.add(element["label"]+"填写数据有误，请检查是否填写完整！");
          }
        });
      }
      return errors;
    }

    function getDelieveryZoneName(branch, delivery_zone_id){
      if(branch){
        var array = branch.delivery_zones
        for (var d = 0, len = array.length; d < len; d += 1) {
          if (array[d].id === delivery_zone_id) {
              return array[d].zone_name;
          }
        }
      }
    }

    function send_phone_validation_code(branch){
      var url = "/"+[baseURL, "branches", branch.id, "order", "send_phone_validation_code", order.phone.toString()+".json"].join("/");
      var input_code_is_disabled = false;
      $http.get(url).error(function(message){
        input_code_is_disabled = true;
        alert(message["message"]);
      });
      return input_code_is_disabled;
    }

    function do_validate_code(branch, order, code){
      var url = "/"+[baseURL, "branches", branch.id, "order", "validation_code.json"].join("/");
      var data = {phone: order.phone, code: code, authenticity_token: $('meta[name=csrf-token]').attr('content')};
      return $http.post(url, data);
    }

    function set(branch, member, order_new){
      if(typeof(branch) == "undefined" || typeof(member) == "undefined"){
        return false;
      }
      if(typeof(order_new) != "undefined"){
        order = order_new;
        return false;
      }
      order = {};
      order.name = member.name;
      order.phone = member.phone;
      order.address = member.default_address;
      order.order_type = 'delivery';
      order.guest_num = 1;
      order.form_contents_attributes = {};
      if(typeof(branch.form_elements) != "undefined"){
        angular.forEach(branch.form_elements, function(element, index){
          var content = null;
          if(typeof(element.options) != "undefined" && typeof(element.options[0]) != "undefined"){
            content = element.options[0].html;
          }
          order.form_contents_attributes[index]={content: content, label: element.label, form_element_id: element.id};
        });
      }
    }

    function commit(branch, member){
      var data = {order_webstore: get(), authenticity_token: $('meta[name=csrf-token]').attr('content')};
      var url = "/"+[baseURL, "branches", branch.id, "orders.json"].join("/");
      return $http.post(url, data);
    }

    function clear(){
      order = undefined;
    }

    function get(){
      return order;
    }

    var orders = undefined;

    function all(success){
      if(orders){
        success(orders);
      }else{
        $http.get(baseURL+"/orders.json").then(function(response){
           orders = response.data;
           success(orders);
        });
      }
    }

    return {
      all:all,
      get: get,
      set: set,
      commit: commit,
      types: types,
      clear: clear,
      guest_numbers: guest_numbers,
      getDelieveryZoneName: getDelieveryZoneName,
      send_phone_validation_code: send_phone_validation_code,
      do_validate_code: do_validate_code,
      validate_phone: validate_phone,
      validate_validation_code: validate_validation_code,
      validate_form: validate_form
    }
  }]);