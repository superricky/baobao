#encoding: utf-8
class Trade < ActiveRecord::Base
  include WechatUtils
  WEIXINPAY = "weixinpay"

  belongs_to :order, :foreign_key=>"out_trade_no"
  belongs_to :shop
  belongs_to :branch
  has_many :weixinpay_feedbacks
  validates_presence_of :shop, :branch, :order
  default_scope {order("created_at DESC")}

  after_create :update_order_paid_state


  def trade_type_name
    if trade_type == Order::PAY_BY_WEIXIN_TYPE
      '微信支付'
    elsif trade_type == Order::PAY_BY_TENPAY_TYPE
      '财付通支付'
    elsif trade_type == Order::PAY_BY_MOBILE_ALIPAY_TYPE
      '支付宝手机支付'
    end
  end

  def update_order_paid_state
    self.order.update_attribute(:is_paid, true)
    material = Material.new(
      :msg_type=>'news')
    material.articles.build({
      :title=>"订单#{self.order.id}已成功支付",
      :description=> "#{self.order.order_detail}"
      })
    sc = self.system_config
    begin
      send_custom_message(material, self.order.user.fake_user_name, sc.appId, sc.appSecret)
    rescue =>e
      Rails.logger.warn e.message
    end
  end

  def system_config
    self.order.user.system_config rescue self.shop.system_configs.varified_service_account.where(:partnerId=>partner).first rescue nil
  end
end
