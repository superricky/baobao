#encoding: utf-8
class ServiceProduct < ActiveRecord::Base
  attr_accessor :amount

  SERVICE_PRODUCT_TYPE_SMS_MSG = "recharge_sms_msg"
  SERVICE_PRODUCT_TYPE_ORDER = "recharge_order"
  SERVICE_PRODUCT_TYPE_TIME = "recharge_time"
  SERVICE_PRODUCT_TYPES =  [SERVICE_PRODUCT_TYPE_ORDER, SERVICE_PRODUCT_TYPE_TIME, SERVICE_PRODUCT_TYPE_SMS_MSG]
  acts_as_list
  default_scope {order("position ASC")}
  has_many :service_sale_orders

  validates_presence_of :price, :quantity, :description, :subject, :available_shop_versions
  validates_numericality_of :price, :greater_or_equal_than => 0
  validates_numericality_of :quantity, :greater_or_equal_than => 0
  validate :check_version_valid

  def amount
    self.price * self.quantity
  end

  def is_recharge_sms_msg?
    product_type == SERVICE_PRODUCT_TYPE_SMS_MSG
  end

  def is_recharge_order?
    product_type == SERVICE_PRODUCT_TYPE_ORDER
  end

  def is_recharge_time?
    product_type == SERVICE_PRODUCT_TYPE_TIME
  end

  def self.product_type_name(key)
    I18n.t "activerecord.attributes.service_product.product_type_name.#{key}"
  end

  def product_type_name
    ServiceProduct::product_type_name(self.product_type)
  end

  def available_shop_versions
    self.read_attribute(:available_shop_versions).split(",") rescue nil
  end

  def available_shop_versions=(value)
    super(value.select{|v| v.present? }.join(","))
  end

  def is_availbale_for_shop(shop)
    if self.available_shop_versions.present?
      self.available_shop_versions.include? shop.version
    else
      false
    end
  end

  private
  def check_version_valid
    self.errors.add(:available_shop_versions,
      "为[#{(available_shop_versions - available_shop_versions_for_product_type).map{|t| Shop::version_name(t)}.join('、')}]的产品不可以选择产品类型为[#{self.product_type_name}]") if (available_shop_versions - available_shop_versions_for_product_type).present?
  end

  def available_shop_versions_for_product_type
    if is_recharge_time?
      [Shop::VERSION_SINGLE_VIP, Shop::VERSION_MULTIPLE_VIP]
    elsif is_recharge_order?
      [Shop::VERSION_MULTIPLE_BASE]
    elsif is_recharge_sms_msg?
      [Shop::VERSION_MULTIPLE_BASE, Shop::VERSION_SINGLE_VIP, Shop::VERSION_MULTIPLE_VIP]
    end
  end
end
