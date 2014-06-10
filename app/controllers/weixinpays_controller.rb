#encoding: utf-8
class WeixinpaysController < ApplicationController
  skip_load_and_authorize_resource
  authorize_resource :class => false
  protect_from_forgery :except => [:notify_weixin_pay_result, :priority_notify, :warning]
  before_filter :validate_user_info
  before_filter :set_order, only: [:weixin_pay_params, :notify_weixin_pay_result]
  before_filter :validate_notify, only: [:notify_weixin_pay_result]
  before_filter :validate_priority_notify, only: :priority_notify
  include WeixinPay
  include WechatUtils

  def weixin_pay_params
    system_config = @current_user.system_config
    nonce_str = SecureRandom.uuid.to_s
    pay_params = {}
    pay_params[:appId] = system_config.appId
    pay_params[:timeStamp] = Time.now.to_i.to_s
    pay_params[:nonceStr] = nonce_str
    @order.nonce_str = nonce_str
    pay_params[:package] = package_str("订单#{@order.id}",
      nil,system_config.partnerId, system_config.partnerKey, @order.id.to_s,
      @order.cash_amount, notify_weixin_pay_result_weixinpay_url(@current_shop),
      request.remote_ip, nil, nil, nil, nil, nil)
    pay_params[:signType] = "sha1"
    pay_params[:paySign] = paySign_str(pay_params[:appId],
      pay_params[:timeStamp], pay_params[:nonceStr], pay_params[:package], system_config.paySignKey)
    if @order.save!
      render json: pay_params.to_json
    else
      render status: :bad_request
    end
  end

  def notify_weixin_pay_result
    if @order.present?
      unless @order.trade.present?
        @order.create_trade(:trade_id=>params[:transaction_id],
          :trade_type=>Order::PAY_BY_WEIXIN_TYPE,
          :query=>request.query_string,
          :body=>@body_xml,
          :partner=>params[:partner],
          :total_fee=>params[:total_fee],
          :out_trade_no=>params[:out_trade_no],
          :shop_id=>@order.shop_id,
          :branch_id=> @order.branch_id)
      end
      render inline: "success"
    end
  end

  def priority_notify
    @current_shop.weixinpay_feedbacks.create!(
      :feedback_id => @notify_xml[:FeedBackId],
      :openid => @notify_xml[:OpenId],
      :appid => @notify_xml[:AppId],
      :trade_id => @notify_xml[:TransId],
      :body => @body_xml,
      :msg_type=> @notify_xml[:MsgType]
      )
    render inline: "success"
  end

  def warning
    body_xml = request.body.read
    warning_xml = Hash.from_xml(body_xml).to_options[:xml].to_options
    system_config = @current_shop.system_configs.find_by_appId(warning_xml[:AppId])
    warning_xml = Hash.from_xml(body_xml).to_options[:xml].to_options
    if system_config.present?
      @current_shop.weixinpay_warnings.create({
        :appId => warning_xml[:AppId],
        :error_type => warning_xml[:ErrorType],
        :description => warning_xml[:Description],
        :alarm_content => warning_xml[:AlarmContent],
        :body => body_xml
        })
      render inline: "success"
    end
  end

  private

  def set_order
    @order = @current_shop.orders.find(params[:order_id]||params[:out_trade_no])
  end

  def validate_priority_notify
    @body_xml = request.body.read
    @notify_xml = Hash.from_xml(@body_xml).to_options[:xml].to_options
    system_config = @current_shop.system_configs.find_by_appId(@notify_xml[:AppId])
    body = {
      :appid=> @notify_xml[:AppId],
      :appkey=> system_config.paySignKey,
      :timestamp=> @notify_xml[:TimeStamp],
      :openid=> @notify_xml[:OpenId]
    }
    unless @notify_xml[:AppSignature] == Digest::SHA1.hexdigest(body.sort.map{|field| field.join("=")}.join("&"))
      raise 'AppSignature is incorrect'
    end
  end

  def validate_notify
    @body_xml = request.body.read
    @notify_xml = Hash.from_xml(@body_xml).to_options[:xml].to_options
    system_config = @current_shop.system_configs.find_by_appId(@notify_xml[:AppId])

    body = {
      :appid=> @notify_xml[:AppId],
      :appkey=> system_config.paySignKey,
      :timestamp=> @notify_xml[:TimeStamp],
      :noncestr=> @notify_xml[:NonceStr],
      :openid=> @notify_xml[:OpenId],
      :issubscribe=> @notify_xml[:IsSubscribe]}
    unless @notify_xml[:AppSignature] == Digest::SHA1.hexdigest(body.sort.map{|field| field.join("=")}.join("&"))
      raise 'AppSignature is incorrect'
    end
  end
end
