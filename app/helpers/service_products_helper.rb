module ServiceProductsHelper

  def is_able_to_show_for(service_product)
    @current_shop.nil? or service_product.is_recharge_sms_msg? or @current_shop.support_auto_buy_service?
  end

end
