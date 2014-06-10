#encoding: utf-8
class ServiceSaleOrder < ActiveRecord::Base
  attr_accessor :amount
  belongs_to :shop
  default_scope {order("created_at DESC")}
  belongs_to :service_product
  has_one :transaction_log
  validates_presence_of :service_product, :shop

  validate :validate_available_products, on: :create

  after_find do
    if self.created_at < 12.hours.ago and self.current_state == :new
      self.fail!
    end
  end

  def amount
    self.price * self.quantity
  end

  include Workflow
  workflow do
    state :new do
      event :verify, :transitions_to => :finished
      event :fail, :transitions_to => :closed
    end
    state :finished
    state :closed
  end

  def verify(params)
    begin
      if service_product.is_recharge_order?
        shop.recharge_order!(params[:buyer_email], service_product.quantity, self)
      elsif service_product.is_recharge_time?
        shop.recharge_date!(params[:buyer_email], service_product.quantity, self)
      elsif service_product.is_recharge_sms_msg?
        #充值短信无需修改商户状态
        shop.recharge_sms_msgs(params[:buyer_email], service_product.quantity, self)
      end
    rescue =>e
      Rails.logger.error e.message
      raise ActiveRecord::Rollback
    end
  end

  def fail
  end

  def workflow_state_name
    I18n.t "activerecord.attributes.service_sale_order.workflow_state_name.#{workflow_state}"
  end

  private
  def validate_available_products
    unless self.service_product.is_availbale_for_shop(self.shop)
      self.errors.add(:base, "您的账户类型不允许购买此类产品")
    end
  end
end
