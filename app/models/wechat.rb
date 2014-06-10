#encoding:utf-8
class Wechat
  require 'faraday-cookie_jar'
  attr_accessor :username, :password
  attr_accessor :errors

  def initialize(username=nil, password=nil)
    self.username = username
    self.password = password
  end

  def valid?
    self.errors[:username] = "微信公众帐户用户名非法" unless username.present?
    self.errors[:password] = "微信公众帐户密码非法" unless password.present?
    self.errors.any?
  end

  def init(shop, host, system_config_id)
    @shop = shop
    @host = host
    @system_config_id = system_config_id
    @conn = Faraday.new(:url => 'https://mp.weixin.qq.com') do |faraday|
      faraday.use :cookie_jar
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def login
    pwd = Digest::MD5.hexdigest(password.to_s)
    response = @conn.post do |req|
      req.url "/cgi-bin/login?lang=zh_CN"
      req.headers['Referer'] = 'https://mp.weixin.qq.com'
      req.headers['Host'] = 'mp.weixin.qq.com'
      req.headers['User-Agent'] = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)'
      req.body = {:username=>username, :pwd=>pwd}
    end

    responseBody = ActiveSupport::JSON.decode(response.body).to_options[:base_resp].to_options
    Rails.logger.info responseBody
    if responseBody[:ret] == 0
      @token = CGI.parse(ActiveSupport::JSON.decode(response.body).to_options[:redirect_url])["token"][0] rescue nil
      @slave_user = CGI::Cookie::parse(response.headers['set-cookie']).to_options[:slave_user][0]
      true
    else
      false
    end

  end

  def toggle_dev_mode(flag=nil, type=nil)
    response = @conn.post do |req|
      req.url "/misc/skeyform?form=advancedswitchform&lang=zh_CN"
      req.headers['Referer'] = 'https://mp.weixin.qq.com'
      req.headers['Host'] = 'mp.weixin.qq.com'
      req.headers['User-Agent'] = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)'
      req.body = {:flag=>flag, :type=>type, :token=>@token}
    end
    Rails.logger.info response.to_json
    Rails.logger.info response.body
    responseBody = ActiveSupport::JSON.decode(response.body).to_options
    Rails.logger.info responseBody.to_json
  end

  def api_url
    "#{@host}/shop/#{@shop.slug}/api"
  end

  def configure_callback
    uuid = "tuodanbao"
    system_config = @shop.system_configs.find(@system_config_id) rescue nil if @system_config_id.present?
    if system_config.nil?
      system_config = @shop.system_configs.create(:token=>uuid, :my_fake_id=>@slave_user)
    else
      system_config.token = uuid
      system_config.my_fake_id = @slave_user
      system_config.save!
    end
    response = @conn.post do |req|
      req.url "/advanced/callbackprofile?t=ajax-response&token=#{@token}&lang=zh_CN"
      req.headers['Referer'] = 'https://mp.weixin.qq.com'
      req.headers['Host'] = 'mp.weixin.qq.com'
      req.headers['Origin'] = 'https://mp.weixin.qq.com'
      req.headers['User-Agent'] = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)'
      req.body = {:url=> api_url, :callback_token=> system_config.token}
    end
    Rails.logger.info response.to_json
    responseBody = ActiveSupport::JSON.decode(response.body).to_options
    Rails.logger.info responseBody.to_json
    system_config
  end

  def config_dev_profile(system_config)
    profile_content = load_profile
    doc = Nokogiri::HTML(profile_content)
    is_service_account = doc.xpath('//li[@class="account_setting_item"]').select{|node| node.xpath('./div[@class="meta_content"]').text.strip =="服务号"}.length == 1 rescue nil
    is_not_verified = doc.xpath('//li[@class="account_setting_item"]').select{|node| node.xpath('./div[@class="meta_content"]').text.strip =="未认证"}.length == 1 rescue nil
    system_config.gonghao_type = !is_service_account
    system_config.be_verified = !is_not_verified
    system_config.public_account_name = doc.xpath('//li[@class="account_setting_item"]/div[@class="meta_content"]')[1].text.strip
    system_config.public_account_name += "("+doc.xpath('//li[@class="account_setting_item"]/div[@class="meta_content"]')[4].text.strip+")"
    develop_config_content = load_develop_config
    develop_doc = Nokogiri::HTML(develop_config_content)
    unless system_config.gonghao_type and !system_config.be_verified

      system_config.appId = develop_doc.xpath('//div[@class="frm_input_box"]')[2].text.strip rescue nil
      system_config.appSecret = develop_doc.xpath('//div[@class="frm_input_box"]')[3].text.strip rescue nil
    end
    validate_config_success(doc, develop_doc, system_config)
    system_config.save!
    system_config
  end

  def validate_config_success(profile_doc, develop_config_doc, system_config)
    raise "公众帐号原始ID配置不正确" if profile_doc.xpath('//li[@class="account_setting_item"]').
      select{|node| node.xpath('./div[@class="meta_content"]').text.strip ==system_config.my_fake_id} rescue nil
    raise "公众帐号URL配置不正确" if develop_config_doc.xpath('//div[@class="frm_input_box"]')[0].text.strip != api_url rescue nil
    raise "公众帐号URL配置不正确" if develop_config_doc.xpath('//div[@class="frm_input_box"]')[1].text.strip != system_config.token rescue nil
    unless system_config.gonghao_type and !system_config.be_verified
      raise "公众帐号appId配置不正确" if develop_config_doc.xpath('//div[@class="frm_input_box"]')[2].text.strip != system_config.appId rescue nil
      raise "公众帐号appSecret配置不正确" if develop_config_doc.xpath('//div[@class="frm_input_box"]')[3].text.strip != system_config.appId rescue nil
    end
  end

  def load_profile
    response = @conn.get "/cgi-bin/settingpage?t=setting/index&action=index&token=#{@token}&lang=zh_CN" do |req|
      req.headers[:accept_encoding] = 'none'
    end
    content = response.body.to_s
  end

  def load_develop_config
    response = @conn.get "/advanced/advanced?action=dev&t=advanced/dev&token=#{@token}&lang=zh_CN" do |req|
      req.headers[:accept_encoding] = 'none'
    end
    content = response.body.to_s
  end

  def inflate(string)
    zstream = Zlib::Inflate.new
    buf = zstream.inflate(string)
    zstream.finish
    zstream.close
    buf
  end
end