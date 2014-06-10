#encoding:utf-8;
module Webstore::OrderHelper
  def order_type_options
    [
      ["外送", Order::ORDERTYPE_DELIVERY],
      ["堂吃", Order::ORDERTYPE_EAT_IN_HALL],
      ["预订", Order::ORDERTYPE_ORDER_SEAT]
    ]
  end
end
