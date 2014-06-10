class Message < ActiveRecord::Base
  #validates :msg_id, presence:true
  MSGTYPES = [[I18n.t("material.text"), :text], [I18n.t("material.music"),:music], [I18n.t("material.news"),:news]]
  belongs_to :message_thread, touch: true
  has_one :user, through: :message_thread
  has_many :articles, -> { order("position ASC") }, dependent: :destroy, as: :owner
  scope :leave_messages, -> {where(:is_leave_msg=>true)}
  default_scope { order("created_at DESC") }

  ransacker :time, :formatter => proc {|v| Date.today - 1.send(v) } do |parent|
    parent.table[:created_at]
  end

  def shop
    self.message_thread.shop
  end

  def self.access_token(code, system_config)
    conn = get_faraday('https://api.weixin.qq.com')
    access_token_params = {
      appid: system_config.appId,
      secret: system_config.appSecret,
      code: code,
      grant_type: "authorization_code"
    }
    content = {}
    3.times do
      response = conn.post do |req|
        req.url "/sns/oauth2/access_token"
        req.body = access_token_params.to_param
      end
      content = JSON.parse(response.body)
      if content["refresh_token"].present?
        return content
      end
    end
    content
  end

  def self.get_global_access_taken(system_config)
    if system_config.access_token.present? && system_config.last_update_access_token_at.present? && (Time.now - system_config.last_update_access_token_at < 7190)
      system_config.access_token
    else
      conn = get_faraday('https://api.weixin.qq.com')
      global_access_token_params = {
        appid: system_config.appId,
        secret: system_config.appSecret,
        grant_type: "client_credential",
      }
      response = conn.post do |req|
        req.url "/cgi-bin/token"
        req.body = global_access_token_params.to_param
      end
      if JSON.parse(response.body)["access_token"].present?
        system_config.update_attributes(access_token: JSON.parse(response.body)["access_token"], last_update_access_token_at: Time.now)
        JSON.parse(response.body)["access_token"]
      end
    end
  end

  def self.user_info(openid, system_config)
    User.get_user_info_by_access_taken(openid, get_global_access_taken(system_config))
  end

  def self.get_faraday(url)
    conn = Faraday.new(:url => url) do |faraday|
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def self.get_ticket(system_config, user, shop)
    conn = get_faraday('https://api.weixin.qq.com')
    scene_id = User.get_max_scene_id_value(shop) + 1
    if user.update_attributes(scene_id: scene_id)
      global_ticket_params = {
        action_name: "QR_LIMIT_SCENE",
        action_info: {scene: {scene_id: scene_id}}
      }
      response = conn.post do |req|
        req.url "/cgi-bin/qrcode/create?access_token=#{get_global_access_taken(system_config)}"
        req.headers['Content-Type'] = 'application/json'
        req.body = global_ticket_params.to_json
      end
      JSON.parse(response.body)["ticket"]
    end
  end

  def is_text?
    msg_type == 'text'
  end

  def is_music?
    msg_type == 'music'
  end

  def is_news?
    msg_type == 'news'
  end
end