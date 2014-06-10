require 'setting'
module SmsMsgsHelper

  def get_show_sms_msg_path(sms_msg)
    if @current_branch
      [:backend, @current_shop, @current_branch, sms_msg]
    else
      [:backend, @current_shop, sms_msg]
    end
  end

  def get_index_sms_msg_path
    if @current_branch
      backend_shop_branch_sms_msgs_path(@current_shop, @current_branch)
    else
      backend_shop_sms_msgs_path(@current_shop)
    end
  end

  def get_search_sms_msg_path
    if @current_branch
      search_backend_shop_branch_sms_msgs_path(@current_shop, @current_branch)
    else
      search_backend_shop_sms_msgs_path(@current_shop)
    end
  end

  def cut_body(body)
    if body.present? and body.length > 20
      "#{body.slice(0, 19)}..."
    else
      body
    end
  end

  def get_sme_msgs_type_array
    [
      ["全部类型",""],
      ["订单短信", SmsMsg::ORDERMSG_TYPE_ORDER],
      ["验证码短信", SmsMsg::ORDERMSG_TYPE_VALIDATE_CODE],
      ["自定义短信", SmsMsg::ORDERMSG_TYPE_CUSTOME]
    ]
  end

  def send_order_msg(order)
    if order.branch.use_sms and order.branch.shop.use_sms and order.branch.supported_send_sms_order_types.include?(order.order_type)
       sms_content_array = get_sms_msg_content_array_by_order(order)
       unless sms_content_array.nil?
        body = "您的商户#{sms_content_array[0]}有新的订单了，商品项目：#{sms_content_array[1]}，订单详情：#{sms_content_array[2]}。【】"
        send_msg_with_sms_template(order.branch, order.branch.sms_to, sms_content_array, body, "1050", 1, SmsMsg::ORDERMSG_TYPE_ORDER, nil)
       end
    end
  end

  def send_cancel_order_msg(order)
    if order.branch.use_sms and order.branch.shop.use_sms
      sms_content_array = [order.branch.name, get_sms_order_cancel_and_remind_by_type(order), "取消了" , "#{order.id}"]
      unless sms_content_array.nil?
        body = "商户#{sms_content_array[0]}的客户#{sms_content_array[1]}，#{sms_content_array[2]}编号为#{sms_content_array[3]}的订单，请及时调整生产与配送。【】"
        send_msg_with_sms_template(order.branch, order.branch.sms_to, sms_content_array, body, "1206", 1, SmsMsg::ORDERMSG_TYPE_ORDER, nil)
      end
    end
  end

  def send_remind_order_msg(order)
    if order.branch.use_sms and order.branch.shop.use_sms and order.branch.allow_remind_order_msg
      sms_content_array = [order.branch.name, get_sms_order_cancel_and_remind_by_type(order), "在#{(order.last_remind_date.strftime("%H:%M") rescue nil)}已催过" , "#{order.id}"]
      unless sms_content_array.nil?
        body = "商户#{sms_content_array[0]}的客户#{sms_content_array[1]}，#{sms_content_array[2]}编号为#{sms_content_array[3]}的订单，请及时调整生产与配送。【】"
        send_msg_with_sms_template(order.branch, order.branch.sms_to, sms_content_array, body, "1206", 1, SmsMsg::ORDERMSG_TYPE_ORDER, nil)
      end
    end
  end

  def send_scrachpad_msg(order)
    if order.branch.use_sms and order.branch.shop.use_sms and order.branch.split_supported_send_sms_order_types.include?(order.order_type)
       sms_content_array = get_sms_msg_content_array_to_scrachpad(order)
       unless sms_content_array.nil?
        body = "在#{sms_content_array[0]}订餐的客户刮奖了，订单详情：#{sms_content_array[1]}，刮刮奖结果：#{sms_content_array[2]}。【】"
        send_msg_with_sms_template(order.branch, order.branch.sms_to, sms_content_array, body, "1051", 1, SmsMsg::ORDERMSG_TYPE_ORDER, nil)
       end
    end
  end

  def send_custom_msg(branch, to, body, type)
    send_msg(branch, to, body, type, SmsMsg::ORDERMSG_TYPE_CUSTOME, nil)
  end

  def send_validation_msg(branch, user, phone)
    shop = branch.shop
    unless branch.use_sms_validation and branch.shop.use_sms_validation
      raise BranchOrShopNotUseSmsValidation, "该点账号或商户未开通短信或者不支持验证码"
    end
    if user.last_sent_validation_code_time.present?
      if(user.last_sent_validation_code_time + 1.minute > Time.now)
        raise SmsMsgTooFrequently, "至少需要等待一分钟才能再次发送验证短信"
      end

      if (user.last_sent_validation_code_time.strftime("%Y-%m-%d")== Time.now.strftime("%Y-%m-%d")) and
         (user.sent_validation_code_times_in_today >= shop.max_validation_code_times_in_day)
        raise ValidationSmsMsgOverLimit, "当日您最多能接收#{shop.max_validation_code_times_in_day}条验证短信，请确认手记号码是否正确"
      end
    end
    data = [branch.name, user.get_validation_code.code, "60"]
    body = "您在商户#{data[0]}上的验证码为：#{data[1]},该验证码1小时内有效。"
    send_msg_with_sms_template(branch, phone, data, body, "1049", 0, SmsMsg::ORDERMSG_TYPE_VALIDATE_CODE, user)
  end

  private

  def send_msg(branch, to, body, type, order_msg_type, user)

    if (branch.max_sms_count <= branch.sms_msgs_count)
      raise SmsMsgNoFeeException, "商户剩余短信数量不足"
    end

    shop = branch.shop
    if (shop.max_sms_count <= shop.sms_msgs_count)
      raise SmsMsgNoFeeException, "点号管理员所购买的剩余短信数量不足"
    end

    conn = Faraday.new Settings.sms.host do |faraday|
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter

    end
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    response = conn.post do |req|
      req.url  "/#{Settings.sms.soft_version}/Accounts/#{Settings.sms.account_sid}/SMS/Messages", 'sig'=>sig_parameter(Settings.sms.account_sid,timestamp)
      req.headers['Accept'] = Settings.sms.accept
      req.headers['Content-Type'] = Settings.sms.content_type
      req.headers['Authorization'] = authorize(Settings.sms.account_sid, timestamp)
      req.params[:sig]="#{sig_parameter(Settings.sms.account_sid,timestamp)}"
      smsMessage = {}
      smsMessage[:to] = to
      smsMessage[:body] = body
      smsMessage[:msgType] = type.to_s
      smsMessage[:appId] = Settings.sms.app_id
      smsMessage[:subAccountSid] =  Settings.sms.sub_account_sid
      req.body = smsMessage.to_xml(:root=>"SMSMessage")
      logger.info "body = #{req}"
    end
    response_body = response.body
    #response_body = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Response>  <statusCode>000000</statusCode>  <SMSMessage>    <smsMessageSid>ff8080813c373cab013c94b0f0512345</smsMessageSid>    <dateCreated>2013-02-01 15:38:09</dateCreated>  </SMSMessage></Response>'
    logger.info response_body
    response = Hash.from_xml(response_body).to_options[:Response].to_options
    msg = branch.sms_msgs.build
    if response[:statusCode] == "000000"
      responseMsg = response[:SMSMessage].to_options
      msg.sms_message_id = responseMsg[:smsMessageSid]
      msg.date_created = responseMsg[:dateCreated]
      msg.to = to
      msg.body = body
      msg.sms_msg_owner = user
      msg.order_msg_type = order_msg_type
      if msg.save!
        return msg
      end
    else
      @error ="无法发送短信，错误码为#{response[:statusCode]}"
      logger.warn @error
    end
    nil

  end

  def send_msg_with_sms_template(branch, to, data, body, templateId, type, order_msg_type, user)

    if (branch.max_sms_count <= branch.sms_msgs_count)
      raise SmsMsgNoFeeException, "商户剩余短信数量不足"
    end

    shop = branch.shop
    if (shop.max_sms_count <= shop.sms_msgs_count)
      raise SmsMsgNoFeeException, "点号管理员所购买的剩余短信数量不足"
    end

    conn = Faraday.new Settings.sms.host do |faraday|
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    response = conn.post do |req|
      req.url  "/#{Settings.sms.soft_version}/Accounts/#{Settings.sms.account_sid}/SMS/TemplateSMS", 'sig'=>sig_parameter(Settings.sms.account_sid,timestamp)
      req.headers['Accept'] = Settings.sms.accept
      req.headers['Content-Type'] = Settings.sms.content_type
      req.headers['Authorization'] = authorize(Settings.sms.account_sid, timestamp)
      req.params[:sig]="#{sig_parameter(Settings.sms.account_sid,timestamp)}"
      smsMessage = {}
      smsMessage[:to] = to
      smsMessage[:appId] = Settings.sms.app_id
      smsMessage[:templateId] = templateId
      smsMessage[:datas] = data
      req.body = smsMessage.to_json
      Rails.logger.info "body = #{req}"
    end
    response_body = response.body
    Rails.logger.info response_body
    response = JSON.parse response_body
    msg = branch.sms_msgs.build
    if response["statusCode"] == "000000"
      Rails.logger.info "短信发送成功， 短信内容：#{body}"
      responseMsg = response["templateSMS"]
      msg.sms_message_id = responseMsg["smsMessageSid"]
      msg.date_created = responseMsg["dateCreated"]
      msg.to = to
      msg.order_msg_type = order_msg_type
      msg.body = body
      msg.sms_msg_owner = user
      msg.save!
      return "验证码已发送"
    else
      Rails.logger.error "无法发送短信，错误码为#{response["statusCode"]}, 信息为:#{response["statusMsg"]}"
      raise SmsMsgSendErrorException, "无法发送短信，错误码为:#{response["statusCode"]}"
    end
  end

  def sig_parameter(account_id, timestamp)
    Digest::MD5.hexdigest("#{account_id}#{Settings.sms.auth_token}#{timestamp}").upcase
  end

  def authorize(account_id, timestamp)
    code = Base64.strict_encode64("#{account_id}:#{timestamp}")
    Rails.logger.info Base64.strict_encode64 code
    code
  end

  def get_sms_msg_content_array_by_order(order)
    if get_sms_detail_by_order_type(order).present?
      detail_array = [order.branch.name]
      detail_array << order.order_items.all.map{|order_item| "#{order_item.name}x#{order_item.quantity}"}.join("、")
      detail = "[订单]#{order.id}、[方式]#{order.order_type_name}、[订购时间]#{order.created_at.strftime('%d号%H:%M')}、"

      detail += "#{get_sms_detail_by_order_type(order)}、"

      if order.form_contents.present?
        order.form_contents.each do |record|
          detail += "[#{record.label }]#{record.content}、"
        end
      end

      detail += "[合计]#{order.branch.shop.current_currency_symbol}#{order.amount}元"
      order_strategy = OrderStrategy.new
      if order.consume_credit > 0
        detail += "、[消耗积分]#{order.consume_credit}个、[积分抵扣]#{order_strategy.money_exchange_from_credits(order.branch.shop, order.consume_credit)}元"
      end
      if order.consume_wallet > 0
        detail += "、[余额抵扣]#{order.branch.shop.current_currency_symbol}#{order.consume_wallet || 0}元"
      end
      detail += "、[实付金额]#{order.branch.shop.current_currency_symbol}#{order.cash_amount || 0}元"

      if order.scrachpad.present?
        if !order.branch.separate_notice_of_praise_and_new_order
          detail += "、[刮刮奖结果]#{order.scrachpad.card_result}"
        else
          detail += "、用户还未刮奖"
        end
      end

      if order.note.present?
        detail += "、[备注]#{order.note})"
      end

      detail_array << detail
    else
      logger.error "不能发送短信给店家，订单号#{order.id}：#{order.to_json}"
    end
  end

  def get_sms_msg_content_array_to_scrachpad(order)
    if get_sms_detail_by_order_type(order).present?
      detail_array = [order.branch.name]
      detail = "[订单]#{order.id}、[方式]#{order.order_type_name}、[订购时间]#{order.created_at.strftime('%d号%H:%M')}、"
      detail += get_sms_detail_by_order_type(order)
      detail_array << detail
      detail_array << (order.scrachpad.card_result rescue "")
    else
      logger.error "不能发送短信给店家，订单号#{order.id}：#{order.to_json}"
    end
  end

  def get_sms_detail_by_order_type(order)
    if order.branch.split_supported_send_sms_order_types.include? order.order_type
      case order.order_type
      when Order::ORDERTYPE_DELIVERY
        delivery_time_str = ""
        delivery_time_str = "、[配送时间]#{order.delivery_time.strftime('%Y-%m-%d %H:%M')}" if order.delivery_time
        if order.delivery_period.present?
          delivery_time_str += "、[配送时间段]#{order.delivery_period}"
        end
        "[姓名]#{order.name}、[电话]#{order.phone}、[配送区域]#{(order.delivery_zone.zone_name rescue nil)} 、[地址]#{order.address}#{delivery_time_str}"
      when Order::ORDERTYPE_EAT_IN_HALL
        "[桌号]#{order.desk_no}、[人数]#{order.guest_num}人"
      when Order::ORDERTYPE_ORDER_SEAT
        arrive_time_str = "、[到店时间]#{order.arrive_time.strftime('%d号%H:%M')}" if order.arrive_time
        "[姓名]#{order.name}、[电话]#{order.phone}、[人数]#{order.guest_num}人#{arrive_time_str}"
      end
    end
  end

  def get_sms_order_cancel_and_remind_by_type(order)
    case order.order_type
    when Order::ORDERTYPE_DELIVERY
      "#{order.name}[姓名]"
    when Order::ORDERTYPE_EAT_IN_HALL
      "#{order.desk_no}[桌号]"
    when Order::ORDERTYPE_ORDER_SEAT
      "#{order.name}[姓名]"
    end
  end
end