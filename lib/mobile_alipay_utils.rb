module MobileAlipayUtils
  require 'builder'
  def mobile_alipay_direct_query(mobile_alipay, order, call_back_url, notify_url )
    "/service/rest.htm?#{direct_params(mobile_alipay, order, call_back_url, notify_url)}"
  end

  def mobile_alipay_execute_url(mobile_alipay, order, call_back_url, notify_url)
    request_token = get_request_token(mobile_alipay, order, call_back_url, notify_url)
    "http://wappaygw.alipay.com/service/rest.htm?#{execute_params(mobile_alipay, request_token)}"
  end

  def get_request_token(mobile_alipay, order, call_back_url, notify_url )
    conn = Faraday.new(:url => "http://wappaygw.alipay.com") do |faraday|
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    response = conn.get mobile_alipay_direct_query(mobile_alipay, order, call_back_url, notify_url)
    if response.status != 200
        Rails.logger.error response
        request_token = nil
    else
      request_token = Hash.from_xml(CGI.parse(response.body)["res_data"][0])["direct_trade_create_res"]["request_token"] rescue nil
    end
    request_token
  end

  def direct_req_data_xml(mobile_alipay, order, call_back_url, notify_url)
    builder = Builder::XmlMarkup.new
    xml = builder.direct_trade_create_req do |b|
      b.subject("订单#{order.id}")
      b.out_trade_no(order.id.to_s)
      b.total_fee(order.cash_amount.to_s)
      b.seller_account_name(mobile_alipay.email)
      b.call_back_url(call_back_url)
      b.notify_url(notify_url)
      b.pay_expire("30")
    end
    xml
  end

  def direct_params(mobile_alipay, order, call_back_url, notify_url)
    url_hash = {}
    url_hash[:service] = 'alipay.wap.trade.create.direct'
    url_hash[:format] = 'xml'
    url_hash[:v] = "2.0"
    url_hash[:partner] = mobile_alipay.pid
    url_hash[:req_id] = SecureRandom.uuid.to_s
    url_hash[:sec_id] = "MD5"
    url_hash[:req_data] = direct_req_data_xml(mobile_alipay, order, call_back_url, notify_url)
    url_hash[:sign] = alipay_pay_sign(url_hash, mobile_alipay.pkey)
    url_hash.to_query
  end

  def execute_req_data_xml(request_token)
    builder = Builder::XmlMarkup.new
    xml = builder.auth_and_execute_req do |b|
      b.request_token(request_token)
    end
    xml
  end

  def execute_params(mobile_alipay, request_token)
    url_hash = {}
    url_hash[:service] = "alipay.wap.auth.authAndExecute"
    url_hash[:format] = "xml"
    url_hash[:v] = "2.0"
    url_hash[:partner] = mobile_alipay.pid
    url_hash[:sec_id] = "MD5"
    url_hash[:req_data] = execute_req_data_xml(request_token)
    url_hash[:sign] = alipay_pay_sign(url_hash, mobile_alipay.pkey)
    url_hash.to_query
  end

  def alipay_pay_sign(url_hash, key)
    url_str = url_hash.sort.map{|field| field.join("=")}.join("&")
    Digest::MD5.hexdigest("#{url_str}#{key}")
  end

  def validate_notify_request(mobile_alipay, body)
    body_hash = Rack::Utils.parse_query(body).to_options
    url_hash = {}
    url_hash[:service] = body_hash[:service]
    url_hash[:v] = body_hash[:v]
    url_hash[:sec_id] = body_hash[:sec_id]
    url_hash[:notify_data] = body_hash[:notify_data]
    url_str = url_hash.map{|field| field.join("=")}.join("&")
    Digest::MD5.hexdigest("#{url_str}#{mobile_alipay.pkey}") == body_hash[:sign]
  end
end