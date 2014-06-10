#encoding: utf-8
class ManagePrinter

  NEW_ORDER_NOTICE = "order"
  PRAISE_NOTICE ="praise"
  REMIND_ORDER = "remind_order"
  CANCEL_ORDER = "cancel_order"

  def initialize(order)
    @order = order
    @branch = order.branch
  end

  def print_orders_to_feyin_printer(notice_type)
    @branch.printers.get_feiyin_printers.each do |printer|
      printer.copy_count.times do|copy_number|
        print_order_to_feyin_printer(notice_type, @order, printer, copy_number+1)
      end
    end
  end

  def print_order_to_feyin_printer(notice_type, order, printer, copy_number)
    if not printer.print_on_order
      Rails.logger.error "没有启用接单自动打印服务。订单信息为#{order.to_json}"
      return
    end
    conn = Faraday.new(:url => 'http://my.feyin.net') do |faraday|
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    query_params = {}
    #deviceNo = "4600116005087352"
    apiKey = printer.apiKey
    current_time = Time.now
    reqTime = (current_time.to_f * 1000).to_i
    msgNo = SecureRandom.uuid #请在validate后也同样添加该号码
    deviceNo = printer.deviceNo
    if notice_type == PRAISE_NOTICE
      detail = detail_to_prize(order, copy_number)
    elsif notice_type == NEW_ORDER_NOTICE
      detail = detail_to_order(order, copy_number)
    elsif notice_type == REMIND_ORDER
      detail = detail_to_remind_order(order, copy_number)
    elsif notice_type == CANCEL_ORDER
      detail = detail_to_cancel_order(order, copy_number)
    end
    memberCode = printer.memberCode
    content_to_validate_for_free_msg = "#{memberCode}#{detail}#{deviceNo}#{msgNo}#{reqTime}#{apiKey}"
    securityCode_for_free_msg = Digest::MD5.hexdigest(content_to_validate_for_free_msg)
    query_params = {
      :msgDetail => detail,
      :apiKey => apiKey,
      :deviceNo => deviceNo,
      :msgNo => msgNo,
      :memberCode => memberCode,
      :reqTime => reqTime,
      :securityCode => securityCode_for_free_msg,
      :mode => 2
    }
    response = conn.post do |req|
      req.url "/api/sendMsg"
      req.body = query_params.to_param
    end
  end

  def detail_to_order(order, copy_number)

    use_formated_msg = false
    customerName = order.name #""
    customerPhone = order.phone #""
    customerAddress = order.address #""
    customerMemo = order.note #"加辣"
    delivery_zone_name = order.delivery_zone.zone_name rescue nil
    msgDetail = ""
    order.order_items.each do |order_item|
      unless msgDetail.empty?
        msgDetail += "||"
      end
      msgDetail += "#{order_item.name}@#{(order_item.price*100).to_i}@#{order_item.quantity}"
    end
    extra2 = order.id
    extra4 = copy_number
    extra3 = order.is_first_order_of_user
    detail = "
当前为第#{copy_number}联
#{order.branch.name}欢迎您订购
订单编号：#{extra2}
用餐方式:#{order.order_type_name}
订购时间：#{order.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
    if order.order_type == Order::ORDERTYPE_DELIVERY
      detail += "
客户姓名：#{customerName}
联系电话：#{customerPhone}
配送区域：#{delivery_zone_name}
送货地址：#{customerAddress}
"
      if order.delivery_time
          detail += "
配送时间：#{order.delivery_time.strftime('%Y-%m-%d %H:%M')}
"
      end
      if order.delivery_period
          detail += "
配送时间段：#{order.delivery_period}
"
      end

      if order.form_contents.present?
        order.form_contents.each do |record|
          detail += "
#{record.label}：#{record.content}
"
        end
      end
    elsif order.order_type == Order::ORDERTYPE_EAT_IN_HALL
      detail += "
桌号:#{@order.desk_no}
就餐人数：#{@order.guest_num}
"

    elsif order.order_type == Order::ORDERTYPE_ORDER_SEAT
      detail += "
客户姓名：#{customerName}
联系电话：#{customerPhone}
用餐人数：#{@order.guest_num}
"
      if order.arrive_time.present?
        detail +="到店时间：#{@order.arrive_time.strftime('%Y-%m-%d %H:%M')}"
      end
    end
      detail += "
商品名称      单价  数量  小计
－－－－－－－－－－－－－－－－
"
    order.order_items.each do |order_item|
      detail +=
"#{order_item.name.ljust(14-order_item.name.length)}#{('%.2f' % order_item.price).ljust(5)}#{order_item.quantity.to_s.rjust(3)}#{('%.2f' % (order_item.price * order_item.quantity)).rjust(7)}
"
    end
    detail += "
备注：#{customerMemo}
是否首次下单：#{extra3}
"
    detail += "－－－－－－－－－－－－－－－－
合计：#{('%.2f' % order.amount)}元"
    if order.consume_credit > 0
      order_strategy = OrderStrategy.new
      detail += "
消耗积分 :#{order.consume_credit}个
积分抵扣 :-#{order_strategy.money_exchange_from_credits(order.shop, order.consume_credit)}元"
    end
    if order.consume_wallet > 0
      detail += "
余额抵扣 : -#{('%.2f' % (order.consume_wallet))}元"
    end
    detail += "
实付金额 : #{('%.2f' % (order.cash_amount || 0))}元
"
    if order.scrachpad.present?
      if !order.branch.separate_notice_of_praise_and_new_order
        detail += "刮刮奖结果:#{order.scrachpad.card_result}
"
      else
        detail += "用户还未刮奖
"
      end
    end
    detail
  end

  def detail_to_remind_order(order, copy_number)
    use_formated_msg = false
    customerName = order.name #""
    customerPhone = order.phone #""
    customerAddress = order.address #""
    customerMemo = order.note #"加辣"
    delivery_zone_name = order.delivery_zone.zone_name rescue nil
    extra2 = order.id
    extra4 = copy_number
    extra3 = order.is_first_order_of_user
    detail = "
当前为第#{copy_number}联
#{order.branch.name}下单的客户在#{(order.last_remind_date.strftime("%H:%M") rescue nil)}已催过此订单
订单编号：#{extra2}
用餐方式:#{order.order_type_name}
订购时间：#{order.created_at.strftime('%m-%d %H:%M:%S')}"
    if order.order_type == Order::ORDERTYPE_DELIVERY
      detail += "
客户姓名：#{customerName}
联系电话：#{customerPhone}
配送区域：#{delivery_zone_name}
送货地址：#{customerAddress}
"
      if order.delivery_time
          detail += "
配送时间：#{order.delivery_time.strftime('%m-%d %H:%M')}
"
      end

      if order.form_contents.present?
        order.form_contents.each do |record|
          detail += "
#{record.label}：#{record.content}
"
        end
      end
    elsif order.order_type == Order::ORDERTYPE_EAT_IN_HALL
      detail += "
桌号:#{@order.desk_no}
就餐人数：#{@order.guest_num}
"

    elsif order.order_type == Order::ORDERTYPE_ORDER_SEAT
      detail += "
客户姓名：#{customerName}
联系电话：#{customerPhone}
用餐人数：#{@order.guest_num}
"
      if order.arrive_time.present?
        detail +="到店时间：#{@order.arrive_time.strftime('%m-%d %H:%M')}"
      end
    end
    detail += "备注：#{customerMemo}
"
    detail += "合计：#{('%.2f' % order.amount)}元"
    if order.consume_credit > 0
      order_strategy = OrderStrategy.new
      detail += "
消耗积分 :#{order.consume_credit}个
积分抵扣 :-#{order_strategy.money_exchange_from_credits(order.shop, order.consume_credit)}元"
    end
    if order.consume_wallet > 0
      detail += "
余额抵扣 : -#{('%.2f' % (order.consume_wallet))}元"
    end
    detail += "
实付金额 : #{('%.2f' % (order.cash_amount || 0))}元
"
    detail
  end

  def detail_to_cancel_order(order, copy_number)
    use_formated_msg = false
    customerName = order.name #""
    customerPhone = order.phone #""
    customerAddress = order.address #""
    customerMemo = order.note #"加辣"
    delivery_zone_name = order.delivery_zone.zone_name rescue nil
    extra2 = order.id
    extra4 = copy_number
    extra3 = order.is_first_order_of_user
    detail = "
当前为第#{copy_number}联
#{order.branch.name}下单的客户取消了此订单
订单编号：#{extra2}
用餐方式:#{order.order_type_name}
订购时间：#{order.created_at.strftime('%m-%d %H:%M:%S')}
取消订单时间：#{order.updated_at.strftime('%m-%d %H:%M:%S')}"
    if order.order_type == Order::ORDERTYPE_DELIVERY
      detail += "
客户姓名：#{customerName}
联系电话：#{customerPhone}
配送区域：#{delivery_zone_name}
送货地址：#{customerAddress}
"
      if order.delivery_time
          detail += "
配送时间：#{order.delivery_time.strftime('%m-%d %H:%M')}
"
      end

      if order.form_contents.present?
        order.form_contents.each do |record|
          detail += "
#{record.label}：#{record.content}
"
        end
      end
    elsif order.order_type == Order::ORDERTYPE_EAT_IN_HALL
      detail += "
桌号:#{@order.desk_no}
就餐人数：#{@order.guest_num}
"

    elsif order.order_type == Order::ORDERTYPE_ORDER_SEAT
      detail += "
客户姓名：#{customerName}
联系电话：#{customerPhone}
用餐人数：#{@order.guest_num}
"
      if order.arrive_time.present?
        detail +="到店时间：#{@order.arrive_time.strftime('%m-%d %H:%M')}"
      end
    end
    detail += "备注：#{customerMemo}
"
    detail += "合计：#{('%.2f' % order.amount)}元"
    if order.consume_credit > 0
      order_strategy = OrderStrategy.new
      detail += "
消耗积分 :#{order.consume_credit}个
积分抵扣 :-#{order_strategy.money_exchange_from_credits(order.shop, order.consume_credit)}元"
    end
    if order.consume_wallet > 0
      detail += "
余额抵扣 : -#{('%.2f' % (order.consume_wallet))}元"
    end
    detail += "
实付金额 : #{('%.2f' % (order.cash_amount || 0))}元
"
    detail
  end

  def detail_to_prize(order, copy_number)
    customerName = order.name #""
    customerPhone = order.phone #""
    customerAddress = order.address #""
    extra2 = order.id
    extra4 = copy_number
    detail = "
当前为第#{copy_number}联
在#{order.branch.name}定餐的客户刮奖结果
刮奖对应的订单编号：#{extra2}
订购时间：#{order.created_at.strftime('%Y-%m-%d %H:%M:%S')}
刮奖客户姓名：#{customerName}
联系电话：#{customerPhone}"
    if order.order_type == Order::ORDERTYPE_DELIVERY
      detail += "
配送区域：#{delivery_zone_name}
送货地址：#{customerAddress}
"
      if order.delivery_time
        detail += "
订餐配送时间：#{order.delivery_time.strftime('%Y-%m-%d %H:%M')}
"
      end
    elsif order.order_type == Order::ORDERTYPE_EAT_IN_HALL
      detail += "
桌号:#{order.desk_no}
就餐人数：#{order.guest_num}
"

    elsif order.order_type == Order::ORDERTYPE_ORDER_SEAT
      detail += "

用餐人数：#{order.guest_num}
到店时间：#{order.arrive_time.strftime('%Y-%m-%d %H:%M')}
"
    end
    if order.scrachpad.present?
        detail += "刮刮奖结果:#{order.scrachpad.card_result}
"
    end
    detail
  end

end