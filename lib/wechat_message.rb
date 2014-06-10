module WechatMessage
  AUTHORIZE_URL = "https://open.weixin.qq.com/connect/oauth2/authorize"
  ACCESS_TOEN_URL = "https://api.weixin.qq.com/sns/oauth2/access_token"
  def response_with_text_msg(from_user_name, to_user_name, content)
    Message.new(
      :msg_type => 'text',
      :from_user_name => from_user_name,
      :content => content,
      :create_time => Time.now.to_i,
      :to_user_name => to_user_name
    )
  end

  def response_with_news_msg(from_user_name, to_user_name, *articles)
    response = Message.new(:msg_type => 'news',:from_user_name => from_user_name,:create_time => Time.now.to_i,:to_user_name => to_user_name)
    response.articles << articles
    response
  end

  def response_with_customer_service(from_user_name, to_user_name)
    Message.new(
      :msg_type => 'transfer_customer_service',
      :from_user_name => from_user_name,
      :create_time => Time.now.to_i,
      :to_user_name => to_user_name
    )
  end


  def oauth_url(appid, redirect_uri, response_type, scope, state)
    # redirect_uri = CGI::escape(redirect_uri.encode(Encoding::GBK))
    url_hash = {}
    url_hash[:appid] = appid
    url_hash[:redirect_uri] = redirect_uri
    url_hash[:response_type] = response_type
    url_hash[:scope] = scope
    url_hash[:state] = state
    "#{AUTHORIZE_URL}?#{url_hash.to_query}#wechat_redirect"
  end

  def oauth_access_token(appid, secret, code, authorization_code)
    url_hash = {}
    url_hash[:appid] = appid
    url_hash[:secret] = secret
    url_hash[:code] = code
    url_hash[:grant_type] = authorization_code
    "#{ACCESS_TOEN_URL}?#{url_hash.to_query}"
  end

end