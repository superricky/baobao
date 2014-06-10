module WeixinPay
  include WechatUtils
  def yuan_to_cent(yuan)
    (yuan * 100).to_i
  end

  def delivery_product(order)
    conn = connect_weixin
    system_config = order.user.system_config
    access_token = fetch_weixin_access_token(conn, system_config.appId, system_config.appSecret)
    if access_token.nil?
        raise "发货失败，无法获得access_token"
    end
    body_info = {
        :appid=> system_config.appId,
        :openid => order.user.fake_user_name,
        :transid => order.trade.trade_id,
        :out_trade_no => order.id,
        :deliver_timestamp => Time.now.to_i.to_s,
        :deliver_status => 1,
        :deliver_msg => "ok"}
    app_signature = body_info.merge({:appkey=> system_config.paySignKey}).sort.map{|field| field.join("=")}.join("&")
    body = body_info.merge({
        :app_signature => Digest::SHA1.hexdigest(app_signature),
        :sign_method => "sha1"
        }).to_json
    puts body
    response = conn.post do |req|
      req.url "/pay/delivernotify?access_token=#{access_token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = body
    end
    logger.info response.to_json
    responseBody = ActiveSupport::JSON.decode(response.body).to_options
    logger.info responseBody[:errcode]
    unless responseBody[:errcode] == 0
      raise responseBody[:errmsg]
    end
    true
  end

  def package_str(body, attach, partner_id, partnerKey,
    out_trade_no, total_fee, notify_url,
    spbill_create_ip, time_start, time_expire,
    transport_fee, product_fee, goods_tag)
    total_fee = yuan_to_cent(total_fee).to_s
    bank_type = "WX"
    fee_type = "1"
    input_charset = "GBK"
    package_hash = {}
    package_hash[:bank_type] = bank_type
    package_hash[:body] = body
    package_hash[:attach] = attach if attach
    package_hash[:partner] = partner_id
    package_hash[:out_trade_no] = out_trade_no
    package_hash[:total_fee] = total_fee
    package_hash[:fee_type] = fee_type
    package_hash[:notify_url] = notify_url
    package_hash[:spbill_create_ip] = spbill_create_ip
    package_hash[:time_start] = time_start if time_start
    package_hash[:time_expire] = time_expire if time_expire
    package_hash[:transport_fee] = transport_fee if transport_fee
    package_hash[:product_fee] = product_fee if product_fee
    package_hash[:goods_tag] = goods_tag if goods_tag
    package_hash[:input_charset] = input_charset
    string1 = package_hash.sort.map{|field| field.join("=")}.join("&")
    stringSignTemp = [string1, "key=#{partnerKey}"].join("&")
    signValue = Digest::MD5.hexdigest(stringSignTemp).upcase!

    package_url_encode_hash = {}
    package_url_encode_hash[:bank_type] = url_encode(bank_type)
    package_url_encode_hash[:body] = body
    package_url_encode_hash[:attach] = url_encode(attach) if attach
    package_url_encode_hash[:partner] = url_encode(partner_id)
    package_url_encode_hash[:out_trade_no] = url_encode(out_trade_no)
    package_url_encode_hash[:total_fee] = url_encode(total_fee)
    package_url_encode_hash[:fee_type] = url_encode(fee_type)
    package_url_encode_hash[:notify_url] = notify_url
    package_url_encode_hash[:spbill_create_ip] = url_encode(spbill_create_ip)
    package_url_encode_hash[:time_start] = url_encode(time_start) if time_start
    package_url_encode_hash[:time_expire] = url_encode(time_expire) if time_expire
    package_url_encode_hash[:transport_fee] = url_encode(transport_fee) if transport_fee
    package_url_encode_hash[:product_fee] = url_encode(product_fee) if product_fee
    package_url_encode_hash[:goods_tag] = url_encode(goods_tag) if goods_tag
    package_url_encode_hash[:input_charset] = url_encode(input_charset)
    string2 = package_url_encode_hash.to_query #.gsub("%3A", "%3a").gsub("%2F", "%2f")
    puts string2
    package = [string2, "sign=#{signValue}"].join("&")
  end

  def paySign_str(appid, timestamp, nonceStr, package_str, appKey)
    paysign_hash = {}
    paysign_hash[:appid] = appid
    paysign_hash[:timestamp] = timestamp
    paysign_hash[:noncestr] = nonceStr
    paysign_hash[:package] = package_str
    paysign_hash[:appkey] = appKey
    string1 = paysign_hash.sort.map{|field| field.join("=")}.join("&")
    puts string1
    Digest::SHA1.hexdigest(string1)
  end

  def url_encode(str)
     CGI::escape(str.encode(Encoding::GBK))
  end

end