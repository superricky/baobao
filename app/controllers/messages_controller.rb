include BranchesHelper
include WechatMessage
require 'uri'
require 'system_material'
class MessagesController < ApplicationController
  protect_from_forgery :except => :create
  before_filter :wrap_message, :add_user, only: [:create]
  before_filter :set_my_fake_id, only: [:create]
  before_filter :validate_weixin, only: [:create]

  include OrdersHelper #需要获得订单信息
  include MessagesHelper

  def oauth
    @article = @current_shop.articles.promotion_articles.where("expiration_time > ?", DateTime.now).find(params[:article_id]) rescue nil
    unless @article.present?
      render "link_error" , layout: "mobile/empty"
      return
    end
    system_config = @current_shop.system_configs.find_by(my_fake_id: params[:my_fake_id])
    openid = Message.access_token(params[:code], system_config)["openid"]
    if openid.nil?
      render "link_error" , layout: "mobile/empty"
      return
    else
      if openid.strip != params[:user_id]
        if !@current_shop.promotion_logs.find_by(article: @article, browser: openid.strip).present?
          browser_nickname = Message.user_info(openid, system_config)["nickname"]
          sharer_nickname = Message.user_info(params[:user_id], system_config)["nickname"]
          @current_shop.promotion_logs.create!(
            article: @article,
            sharer: params[:user_id],
            sharer_nickname: sharer_nickname,
            browser: openid.strip,
            browser_nickname: browser_nickname
            )
        end
        redirect_uri = "#{user_oauth_url(@current_shop.slug, openid)}?my_fake_id=#{params[:my_fake_id]}&article_id=#{@article.id}"
        @url = oauth_url(system_config.appId, redirect_uri, "code", "snsapi_base", 1)
      end
    end
    render :oauth, layout: "mobile/empty"
  end

  def qrCode
    @user = User.find(params[:user_id])
    if @user.ticket
      render :qrCode, layout: "mobile_empty"
    end
  end

  def get_audiences_info
    @user = User.find(params[:user_id])
    @audiences = @user.audiences.limit(params[:limit].to_i)
    respond_to do |format|
      format.js
    end
  end

  def create
    if @message[:msg_type] == 'text'
      handle_event(@message[:content])
    elsif @message[:msg_type] == 'image'
      handle_image_msg
    elsif @message[:msg_type] == 'location'
      handle_location_msg
    elsif @message[:msg_type] == 'link'
      handle_link_msg
    elsif @message[:msg_type] == 'event'
      handle_event(@message[:event_key])
    end

    if @response.present?
      respond_to do |format|
        format.xml #{render xml: body, status: 200}
      end
    else
      head :no_content
    end
  end

  def validate
    if @current_shop.present?
      @current_shop.system_configs.each do |system_config|
        string_array = [system_config.token, params[:timestamp], params[:nonce]]
        if Digest::SHA1.hexdigest(string_array.sort.join) == params[:signature]
          render inline: "#{params[:echostr]}"
          return
        end
      end
    end
    head :no_content
  end

  private

    def handle_event(event_key)
      unless @message[:event] == "SCAN"
        handle_subscribe_event||handle_custom_event(event_key)||handle_location_event||handle_system_event(event_key)||handle_unfound_event
      end
    end

    def handle_qrcode_event(event_key)
      generalize_user = @current_shop.users.where(scene_id: event_key.to_i).first
      unless generalize_user == @user or @user.generalize_user.present? or @user.ticket.present?
        generalize_user.audiences << @user
        @user.set_user_wechat_info
      end
    end

    def handle_location_event
      if @message[:msg_type] == 'event' and @message[:event] == 'LOCATION'
        @user.update_attributes(:last_latitude => @message[:location_x], :last_longitude =>@message[:location_y], :last_location_time => Time.now)
      end
    end

    def handle_subscribe_event
      if @message[:msg_type] == 'event' and @message[:event] == 'subscribe'
        if @message[:event_key].present?
          key = @message[:event_key].split("_")[1]
          handle_qrcode_event(key)
        end
        judge_event("0")
      end
    end

    def handle_system_event(event_key)
      judge_event(event_key)
    end

    def handle_custom_event(event_key)
      if @message[:event] == "CLICK"
        material = @current_shop.materials.find(event_key) rescue nil
        if material
          handle_event_msg_response(material)
        else
          judge_event(event_key)
        end
      else
        event = @current_shop.events.where(:event_key => event_key).first
        if event
          unless event.is_system_keyword
            handle_event_msg_response(event.material)
          else
            judge_event(event.system_keyword)
          end
        end
      end
    end

    def handle_unfound_event
      if @current_shop.enable_unrecognized_reply_message
        event = @current_shop.events.find_by_event(Event::unmatch_event_str)
        if event && !event.is_system_keyword
          handle_event_msg_response(event.material)
        else
          judge_event((event.system_keyword rescue "0"))
        end
      end
    end

    def judge_event(event)
      case event
      when "0"
        @response = HelpSystemMaterial.new(@my_fake_id, @message[:from_user_name], @current_shop, @user).build_message
      when "1"
        @response = ShopSystemMaterial.new(@my_fake_id, @message[:from_user_name], @current_shop, @user).build_message
      when "2"
        @response = PromotionSystemMaterial.new(@my_fake_id, @message[:from_user_name], @current_shop, @user).build_message
      when "3"
        @response = OrderSystemMaterial.new(@my_fake_id, @message[:from_user_name], @current_shop, @user).build_message
      when "4"
        @response = VipUserSystemMaterial.new(@my_fake_id, @message[:from_user_name], @current_shop, @user).build_message
      when "5"
        @response = GeneralizeSystemMaterial.new(@my_fake_id, @message[:from_user_name], @current_shop, @user).build_message
      when "6"
        @response = QRCodeSystemMaterial.new(@my_fake_id, @message[:from_user_name], @current_shop, @user).build_message
      when /^(5#)\d+/
        article = @current_shop.articles.promotion_articles.find(@message[:content].gsub("5#","")) rescue nil
        if article
          generalize_position_system_material = GeneralizePositionSystemMaterial.new(@my_fake_id, @message[:from_user_name], @current_shop, @user)
          generalize_position_system_material.set_passage(article)
          @response = generalize_position_system_material.build_message
        else
          @response = response_with_text_msg(@my_fake_id, @message[:from_user_name], "您所查询的推广文章不存在。")
        end
      when /^(#绑定#).*$/
        if @user.update_attributes(name: @message[:content].gsub("#绑定#",""))
          @response = GeneralizeSystemMaterial.new(@my_fake_id, @message[:from_user_name], @current_shop, @user).build_message
        else
          @response = response_with_text_msg(@my_fake_id, @message[:from_user_name], "您所查询的推广文章不存在。")
        end
      when /^@.*$/
        @response = response_with_text_msg(@my_fake_id, @message[:from_user_name], "感谢您的留言，#{@current_shop.name}工作人员会尽快察看您的留言并跟您取得联系")
        MessageWorker.perform_in(1.second, @current_shop.id, leave_messages_backend_shop_messages_url(@current_shop.slug))
      else
        @response = response_with_class_name(event)
      end
    end

    def handle_event_msg_response(material)
      if material.msg_type == 'text'
        response_text_msg(material)
      elsif material.msg_type == 'music'
        response_music_msg(material)
      elsif material.msg_type == 'news'
        response_news_msg(material)
      end
    end

    def response_text_msg(material)
      @response = @message_thread.messages.create(
        :msg_type => material.msg_type,
        :from_user_name => @my_fake_id,
        :content => material.content,
        :create_time => Time.now.to_i,
        :to_user_name => @message[:from_user_name]
      )
    end

    def response_music_msg(material)
      @response = @message_thread.messages.create(
        :msg_type => material.msg_type,
        :from_user_name => @my_fake_id,
        :create_time => Time.now.to_i,
        :to_user_name => @message[:from_user_name],
        :title => material.title,
        :description => material.description,
        :music_url => material.music_url,
        :hq_music_url => material.hq_music_url
      )
    end

    def response_news_msg(material)
      decoder = HTMLEntities.new
      @response = @message_thread.messages.build(
        :msg_type => material.msg_type,
        :from_user_name => @my_fake_id,
        :create_time => Time.now.to_i,
        :to_user_name => @message[:from_user_name]
      )
      material.articles.each_with_index do |article,index|
      #logger.info article.to_json
        pic_url = article.image.thumb.url
        if index == 0
          pic_url = article.image.medium.url
        end
        if article.support_promotion
          build_promotion_article(@response, article, pic_url, decoder)
        else
          build_general_article(@response, article, pic_url, decoder)
        end
      end
      @response
    end

    def response_with_class_name(class_name)
      Object.const_get(class_name).new(@my_fake_id, @message[:from_user_name], @current_shop, @user).build_message rescue nil
    end

    def build_general_article(message, article, pic_url, decoder)
      if article.link_type == Article::OUTSIDE_THE_WEB_LINK
        url = article.url
      elsif article.link_type == Article::ARTICLE_SHOW_LINK
        url = mobile_shop_material_show_article_url(@current_shop.slug,article.owner,article)
      elsif article.link_type == Article::SHOP_OR_BRANCH_LINK
        url = wrap_url_with_additional_info(article.url)
      end
      message.articles.build(
        :title => article.title,
        :introduction => article.introduction,
        :description => decoder.decode(ActionView::Base.full_sanitizer.sanitize(article.description)),
        :pic_url => pic_url,
        :url => url
      )
    end

    def build_promotion_article(message, article, pic_url, decoder)
      system_config = @current_shop.system_configs.find_by(my_fake_id: @my_fake_id)
      if system_config.present? && !system_config.gonghao_type && system_config.be_verified && article.expiration_time > DateTime.now
        redirect_uri = "#{user_oauth_url(@current_shop.slug, @user.fake_user_name)}?my_fake_id=#{@my_fake_id}&article_id=#{article.id}"
        url = oauth_url(system_config.appId, redirect_uri, "code", "snsapi_base",1)
        message.articles.build(
          :title => "#{article.title}",
          :introduction => article.introduction,
          :description => decoder.decode(ActionView::Base.full_sanitizer.sanitize(article.description)),
          :pic_url => pic_url,
          :url => url)
      end
    end

    def handle_image_msg
      # head :no_content
    end

    def handle_link_msg
      # head :no_content
    end

    def handle_location_msg
      customer_location = [@message[:location_x], @message[:location_y]]
      @user.update_attributes(:last_latitude => @message[:location_x], :last_longitude =>@message[:location_y], :last_location_label=> @message[:label], :last_location_time => Time.now)
      branches = filter_by_delivery_radius(@current_shop.active_branches.within(10,:origin=>customer_location).sort_by{|e| e.distance_to customer_location}, customer_location)[0,8]
      @response = @message_thread.messages.build(
            :msg_type => 'news',
            :from_user_name => @my_fake_id,
            :create_time => Time.now.to_i,
            :to_user_name => @message[:from_user_name]
          )
      url = @current_shop.enable_new_version? ? client_weixinpay_url(@current_shop.slug) : list_mobile_shop_branches_url(@current_shop.slug)

      if not branches.empty?
        content = "您附近找到#{branches.size}家商户"
        @response.articles.build(
            :title => content,
            :description => '直接进入商户列表',
            :pic_url => get_absolute_url_for_path(@current_shop.image.medium.url),
            :url => wrap_url_with_additional_info(url))
        branches.each_with_index do |branch,index|
          pic_url = get_absolute_url_for_path(branch.image.thumb.url)
          @response.articles.build(
            :title => "#{branch.name}(距您:#{'%0.1f' % branch.distance_to(customer_location)}公里)",
            :description => branch.introduction,
            :pic_url => pic_url,
            :url => @current_shop.enable_new_version? ?  wrap_branch_new_client(@current_shop, branch) : wrap_url_with_additional_info(list_mobile_shop_branch_products_url(@current_shop.slug, branch)))
         end
      else
        content = "对不起，在您附近没有找到合作商户"
        @response.articles.build(
            :title => content,
            :description => '进入商户列表寻找\n\n点击进入>>>',
            :pic_url => get_absolute_url_for_path(@current_shop.image.medium.url),
            :url => wrap_url_with_additional_info(url))
      end
    end

    def set_my_fake_id
      unless @current_shop.nil?
        if not (@current_shop.system_configs.empty? )
          @system_config = @current_shop.system_configs.find_by(my_fake_id: @message[:to_user_name]) rescue nil
          if @system_config.present?
            @my_fake_id = @system_config.my_fake_id
          else
            head :no_content
            return
          end
        end
      end
    end

    def validate_weixin
      if params[:signature].nil? or params[:timestamp].nil? or params[:nonce].nil? or
      @current_shop.nil? or @system_config.nil? or @system_config.token.nil?
        head :no_content
        return
      end

      string_array = [@system_config.token, params[:timestamp], params[:nonce]]
      if string_array.nil?
        head :no_content
      return
      end
      if Digest::SHA1.hexdigest(string_array.sort.join) != params[:signature]
        head :no_content
        return
      end
    end

    def handle_oauth_msg(event)
      system_config = @current_shop.system_configs.find_by(my_fake_id: @my_fake_id)
      unless system_config.present? && !system_config.gonghao_type && system_config.be_verified
        head :no_content
        return
      end
      user = User.find_by_fake_user_name(@message[:from_user_name])
      @response = @message_thread.messages.build(
          :msg_type => 'news',
          :from_user_name => @my_fake_id,
          :create_time => Time.now.to_i,
          :to_user_name => @message[:from_user_name]
        )
      articles = event.material.articles.where("expiration_time > ?", DateTime.now)
      if not articles.empty? and articles.size > 0
        articles.each_with_index do |article,index|
          redirect_uri = "#{user_oauth_url(@current_shop.slug, user.fake_user_name)}?my_fake_id=#{@my_fake_id}&article_id=#{article.id}"
          redirect_uri = CGI::escape(redirect_uri.encode(Encoding::GBK))
          url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{@current_shop.system_configs.find_by(my_fake_id: @my_fake_id).appId}&redirect_uri=#{redirect_uri}&response_type=code&scope=snsapi_base&state=1#wechat_redirect"
          pic_url = get_absolute_url_for_path(article.image.thumb.url)
          @response.articles.build(
            :title => "#{article.title}",
            :description => ActionView::Base.full_sanitizer.sanitize(article.description),
            :pic_url => pic_url,
            :url => url)
        end
      end
      @response
    end

    def wrap_url_with_additional_info(url)
      appendStr = "fakeUserName=#{@user.fake_user_name}&&userId=#{@user.id}&&source=mp.weixin.qq.com"
      if url.nil? or url.empty?
      appendStr
      else
        uri = URI.parse(url)
        if uri.query.nil? or uri.query.empty?
        uri.query = appendStr
        else
          uri.query = uri.query+ "&&" +appendStr
        end
        uri.query += "&&uuid=#{SecureRandom.uuid}"
      uri.to_s
      end
    end

    def wrap_message
      body = request.body.read
      body = Hash.from_xml(body).to_options[:xml].to_options
      @message = {}
      @message[:msg_id] = body[:MsgId]
      @message[:to_user_name] = body[:ToUserName]
      @message[:from_user_name] = body[:FromUserName]
      @message[:create_time] = body[:CreateTime]
      @message[:msg_type] = body[:MsgType]
      @message[:content] = body[:Content]
      @message[:pic_url] = body[:PicUrl]
      @message[:location_x] = body[:Location_X]
      @message[:location_y] = body[:Location_Y]
      @message[:scale] = body[:Scale]
      @message[:label] = body[:Label]
      @message[:title] = body[:Title]
      @message[:description] = body[:Description]
      @message[:url] = body[:Url]
      @message[:event] = body[:Event]
      @message[:event_key] = body[:EventKey]
      if @message[:content].present? and @message[:content].strip.start_with?("@")
        @message[:is_leave_msg] = true
      end
    end

    def add_user
      @user = @current_shop.users.find_by_fake_user_name(@message[:from_user_name])
      if @user.nil?
        @user = @current_shop.users.create!(
          :fake_user_name => @message[:from_user_name],
          :my_fake_id => @message[:to_user_name],
          :subscribe_time => Time.now)
      end

      @message_thread = @user.message_thread
      if @message_thread.nil?
        @message_thread = @user.build_message_thread(:shop_id=>@current_shop.id)
      end

      @message_thread.messages.build(@message)
      @message_thread.save!
    end

end
