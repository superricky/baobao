module TenpayUtils
  def yuan_to_cent(yuan)
    (yuan * 100).to_i
  end

  def tenpay_url(tenpay, order, return_url, notify_url, remote_ip)
    "https://gw.tenpay.com/gateway/pay.htm?#{pay_params(tenpay, order, return_url, notify_url, remote_ip)}"
  end

  def pay_hash(tenpay, order, return_url, notify_url, remote_ip)
    url_hash = {}
    url_hash[:body] = "dingdan"
    url_hash[:subject] = "商品名称"
    url_hash[:return_url] = return_url if return_url.present?
    url_hash[:notify_url] = notify_url if notify_url.present?
    url_hash[:partner] = tenpay.pid
    url_hash[:out_trade_no] = order.id
    url_hash[:total_fee] = yuan_to_cent(order.cash_amount)
    url_hash[:fee_type] = 1
    url_hash[:spbill_create_ip] = remote_ip
    url_hash.sort.map{|field| field.join("=")}.join("&")
  end

  def tenpay_sign(tenpay, order, return_url, notify_url, remote_ip)
    Digest::MD5.hexdigest("#{pay_hash(tenpay, order, return_url, notify_url, remote_ip)}&key=#{tenpay.pkey}").upcase!
  end

  def pay_params(tenpay, order, return_url, notify_url, remote_ip)
    url_hash = {}
    url_hash[:body] = "dingdan"
    url_hash[:subject] = "商品名称"
    url_hash[:return_url] = return_url if return_url.present?
    url_hash[:notify_url] = notify_url if notify_url.present?
    url_hash[:partner] = tenpay.pid
    url_hash[:out_trade_no] = order.id
    url_hash[:total_fee] = yuan_to_cent(order.cash_amount)
    url_hash[:fee_type] = 1
    url_hash[:spbill_create_ip] = remote_ip
    url_hash[:sign] = tenpay_sign(tenpay, order, return_url, notify_url, remote_ip)
    #url_hash.sort.map{|field| field.join("=")}.join("&")
    url_hash.to_query
  end
end