#encoding:utf-8
module OrdersHelper
  include TenpayUtils
  include MobileAlipayUtils
  def get_cart_quantity_by_product_id(product_id)
    if @cart.line_items.find_by_product_id(product_id) and (@cart.line_items.find_by_product_id(product_id).quantity >0)
      @cart.line_items.find_by_product_id(product_id).quantity
    else
      0
    end
  end

  def delivery_charge(order_type, delivery_zone)
    order_strategy = OrderStrategy.new
    order_strategy.delivery_fee(@current_cart, order_type, delivery_zone)
  end

  def delivery_charge_quantity(order_type)
    order_strategy = OrderStrategy.new
    if order_strategy.delivery_fee(@current_cart, order_type, @current_branch.delivery_zones.first) > 0
      1
    else
      0
    end
  end

  def pay_url(order)
    if order.is_tenpay_type?
      tenpay = @current_shop.tenpay
      tenpay_url(tenpay, order, client_order_url(@current_shop, order), notify_tenpay_url(@current_shop), request.remote_ip)
    elsif order.is_mobile_alipay_type?
      mobile_alipay = @current_shop.mobile_alipay
      mobile_alipay_execute_url(mobile_alipay, order, client_order_url(@current_shop, order), notify_mobile_alipay_url(@current_shop))
    end
  end

  def get_amount(cart)
    order_strategy = OrderStrategy.new
    order_strategy.cart_amount_after_discount(cart)
  end

  def get_line_items_count(cart)
    order_strategy = OrderStrategy.new
    order_strategy.cart_quantity(cart)
  end

  def get_sms_msg_content_by_order(order)
    detail = ""
    if order.order_type == Order::ORDERTYPE_DELIVERY
      if order.delivery_time.present?
         detail += "配送时间：#{order.delivery_time.strftime('%H:%M:%S')}"
      end
      detail += "
姓名：#{order.name}
电话：#{order.phone}
地址：#{order.address}
合计：#{('%.2f' % order.amount)}元
"
      if order.note.nil?
        detail += "备注：#{order.note}
"
      end
      detail += order.order_items.map{|order_item| "#{order_item.name}(#{order_item.quantity}x#{order_item.product_unit})"}.join("|")
    else
      logger.error "非外卖订单不能发送短信给店家，订单号#{order.id}：#{order.to_json}"
    end
  end

  def order_detail_in_html(order)
    detail = "<ul>
      <li>
        <ul class='basic_info'>
          <li><span class='order_label'>订单编号</span><span class='order_id'>#{order.id}</span></li>
          <li><span class='order_label'>订单状态</span><span class='order_state'>#{order.state_name}</span></li>
          <li><span class='order_label'>下单时间</span><span class='order_created_at'>#{order.created_at.strftime('%Y-%m-%d %H:%M:%S')}</span></li>
          <li><span class='order_label'>下单方式</span><span class='order_type'>#{order.order_type_name}</span></li>
        </ul>
      </li>
      <li>
        <ul class='pay_info'>
          <li><span class='order_label'>支付方式</span><span class='order_pay_type'>#{order.pay_type_name}</span></li>
          <li><span class='order_label'>支付状态</span><span class='order_pay_state'>#{order.pay_state_name}</span></li>
          <li><span class='order_label'>订单金额</span><span class='order_amount'>#{number_to_currency(order.amount, :unit=> order.shop.current_currency_symbol)}</span></li>"
    if order.consume_credit > 0
      detail += "<li><span class='order_label'>- 积分抵扣</span><span class='order_consume_credit'>#{order.consume_credit}个积分</span></li>"
    end
    if order.consume_wallet > 0
      detail += "<li><span class='order_label'>- 积分抵扣</span><span class='order_consume_wallet'>#{number_to_currency(order.consume_wallet, :unit=> order.shop.current_currency_symbol)}</span></li>"
    end
    detail += "<li><span class='order_label'>实际支付</span><span class='order_cash_amount'>#{number_to_currency(order.cash_amount, :unit=> order.shop.current_currency_symbol)}</span></li>"
    if order.is_weixin_pay_type?
      detail += "<li><span class='order_label'>支付状态</span><span class='order_is_paid'>#{order.is_paid? ? '已支付' : '未支付'}</span>"
    end
    detail += "</ul>
      </li><li><ul class='delivery_info'>"
    if order.is_delivery?
      if order.delivery_time.present?
        detail += "<li><span class='order_label'>配送时间</span><span class='order_delivery_time'>#{order.delivery_time.strftime('%H:%M:%S')}</span></li>"
      end
      detail +="<li><span class='order_label'>客户姓名</span><span class='order_name'>#{order.name}</span></li>
                <li><span class='order_label'>联系电话</span><span class='order_phone'><a href='tel:#{order.phone}'>#{order.phone}</a></span></li>"
      if order.delivery_zone.present?
        detail += "<li><span class='order_label'>配送区域</span><span class='order_delivery_zone'>#{order.delivery_zone.zone_name rescue nil}</span></li>"
      end
      if order.delivery_period
        detail += "<li><span class='order_label'>配送时间段</span><span class='delivery_period'>#{order.delivery_period}</span></li>"
      end
      detail += "<li><span class='order_label'>送货地址</span><span class='order_address'>#{order.address}</span></li>"
    elsif order.is_eat_in_hall?
      detail += "<li><span class='order_label'>桌号</span><span class='order_desk_no'>#{order.desk_no}</span></li>
      <li><span class='order_label'>人数</span><span class='order_guest_num'>#{order.guest_num}</span></li>"
    elsif order.is_order_seat?
      detail += "<li><span class='order_label'>客户姓名</span><span class='order_name'>#{order.name}</span></li>
      <li><span class='order_label'>联系电话</span><span class='order_phone'><a href='tel:#{order.phone}'>#{order.phone}</a></span></li>
      <li><span class='order_label'>人数</span><span class='order_guest_num'>#{order.guest_num}</span></li>"
        if order.arrive_time.present?
          detail += "<li><span class='order_label'>到店时间</span><span class='order_arrive_time'>#{order.arrive_time.strftime('%Y-%m-%d %H:%M')}</span></li>"
        end
    end
    if order.form_contents.present?
      order.form_contents.each do |form_content|
        detail +="<li><span class='order_label'>#{form_content.label}</span><span class='order_form_content'>#{form_content.content}</span></li>"
      end
    end
    detail += "<li><span class='order_label'>备注</span><span class='order_note'>#{order.note}</span></li>" if order.note.present?
    detail += "<li><span class='order_label'>是否首次下单</span><span class='order_is_first_order_of_user'>首次下单</span></li>" if order.is_first_order_of_user
    detail += "<li><span class='order_label'>刮刮奖结果</span><span class='order_scrachpad'>#{order.scrachpad.card_result}</span></li>" if order.scrachpad.present?
    detail += "</ul></li>
    <li><ul class='order_items'>"
    order.order_items.each do |order_item|
      detail += "<li><span class='order_label'>#{order_item.name}</span><span class='order_item_quantity'>数量：#{order_item.quantity} * #{order_item.product_unit}</span></li>"
      end
    detail += "</ul></li>
    </ul>"
  end


  def order_detail_in_text(order)
    detail = "<br/>#{order.branch.name}欢迎您订购<br/>"
    detail += "订单编号：#{order.id}<br/>"
    detail += "下单方式：#{order.order_type_name}<br/>"
    detail += "订购时间：#{order.created_at.strftime('%Y-%m-%d %H:%M:%S')}<br/>"
    if order.order_type == Order::ORDERTYPE_DELIVERY
      if order.delivery_time.present?
        detail += "<br/>"
        detail += "配送时间：#{order.delivery_time.strftime('%H:%M:%S')}"
      end
      detail += "<br/>"
      detail += "客户姓名：#{order.name}<br/>"
      detail += "联系电话：#{order.phone}<br/>"
      if order.delivery_zone.present?
        detail += "配送区域：#{order.delivery_zone.zone_name rescue nil}<br/>"
      end
      if order.delivery_period.present?
        detail += "[配送时间段]#{order.delivery_period}<br/>"
      end
      detail += "送货地址：#{order.address}"
      elsif order.is_eat_in_hall?
        detail += "<br/>"
        detail += "桌号:#{order.desk_no}<br/>"
        detail += "人数：#{order.guest_num}<br/>"
      elsif order.is_order_seat?
        detail += "<br/>"
        detail += "客户姓名：#{order.name}<br/>"
        detail += "联系电话：#{order.phone}<br/>"
        detail += "人数：#{order.guest_num}<br/>"
        if order.arrive_time.present?
          detail += "到店时间：#{order.arrive_time.strftime('%Y-%m-%d %H:%M')}<br/>"
        end
      end
      if order.form_contents.present?
        order.form_contents.each do |form_content|
          detail +="<br/>"
          detail += "#{form_content.label}：#{form_content.content}"
        end
      end
      detail +="<br/>"
      detail += "#{format_string(14, '商品名称')}#{format_string(6, '单价')}#{format_string(6, '数量')}#{format_string(6, '小计')}<br/>"
      detail += "－－－－－－－－－－－－－－－－<br/>"
      order.order_items.each do |order_item|
          detail += "#{format_string(14, order_item.name)}#{('%.2f' % order_item.price).to_s.ljust(9, ' ')}#{order_item.quantity.to_s.ljust(3, ' ')}#{('%.2f' % (order_item.price * order_item.quantity)).to_s.rjust(9, ' ')}<br/>"
      end
      detail += "<br/>备注：#{order.note}<br/>"
      detail += "是否首次下单：#{order.is_first_order_of_user}<br/>"
      if order.scrachpad.present?
        detail += "刮刮奖结果:#{order.scrachpad.card_result}<br/>"
      end
      detail += "－－－－－－－－－－－－－－－－<br/>"
      detail += "合计：#{('%.2f' % order.amount)}元<br/>"
  end

  def format_string(totle_size, str)
    str_s = str.to_s
    str_size = str_s.split('').inject(0) do |sum, s|
      sum += (s.bytesize == 3 ? 2 : 1)
    end
    if totle_size - str_size > 0
      (totle_size - str_size).times do |i|
        str_s += " "
      end
    end
    str_s
  end

end