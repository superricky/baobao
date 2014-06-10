module WechatUtils

  def connect_weixin
    conn = Faraday.new(:url => 'https://api.weixin.qq.com') do |faraday|
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    conn
  end

  def fetch_weixin_access_token(conn, appId, appSecret)
    response = conn.get '/cgi-bin/token', {
      :grant_type => 'client_credential',
      :appid => appId,
      :secret=> appSecret}
    if response.status != 200
        Rails.logger.error response
        access_token = nil
    else
      access_token = ActiveSupport::JSON.decode(response.body).to_options[:"access_token"]
    end
    access_token
  end

  #发送客服消息
  def send_custom_message(material, to_user_open_id, appId, appSecret)
    conn = connect_weixin
    access_token = fetch_weixin_access_token(conn, appId, appSecret)
    body = {
      :touser => to_user_open_id,
      :msgtype => material.msg_type
    }

    if material.is_text?
      body = body.merge({
        :text => {
          :content=> material.content
        }
      })
    elsif material.is_music?
      body = body.merge({
        :music => {
          :title => material.title,
          :description => material.description,
          :musicurl => material.music_url,
          :hqmusicurl => material.hq_music_url,
          :thumb_media_id => nil #必填选项
        }
      })
    elsif material.is_news?
      articles = []
      material.articles.each do |article|
        unless articles.length <= 10
          raise "articles can not be more than 10"
        end
        articles << {
          :title => article.title,
          :description => article.description,
          :url => article.url,
          :picurl => article.pic_url
        }
      end
      body = body.merge({
        :news => {
          :articles => articles
        }
      })
    end

    response = conn.post do |req|
      req.url "/cgi-bin/message/custom/send?access_token=#{access_token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = body.to_json
    end

    logger.info response.to_json
    responseBody = ActiveSupport::JSON.decode(response.body).to_options
    logger.info "errcode = #{responseBody[:errcode]}"
    unless responseBody[:errcode] == 0
      raise responseBody[:errmsg]
    end
    true
  end
end