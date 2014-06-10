#encoding: utf-8
require 'file_size_validator'
require "setting"
class Shop < ActiveRecord::Base
  REGEXDOMAIN = /[a-zA-Z0-9]{1,}\-*[a-zA-Z0-9]{1,}(\.com\.cn|\.net\.cn|\.org\.cn|\.gov\.cn|\.com|\.net|\.cn|\.org|\.co|\.biz|\.info|\.name|\.so|\.me|\.mobi|\.cc)/
  REGEXIP = /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/
  DEFAULT_CURRENCY_SYMBOL = "￥"
  extend FriendlyId
  friendly_id :slug, use: [:slugged, :finders]

  is_impressionable

  validates :name, presence: true, length:{minimum:2}
  validates :slug, presence:true, uniqueness: true, length: {minimum:3}, format:{with: VALID_SHOP_SLUG_REGEX}
  validates :telephone, presence: true
  validates :telephone, format:{with: VALID_PHONE_TEL_REGEX}, if: :need_validate_telephone
  validates :expiration_time, :version_name, :left_order_count, presence: true
  validates_numericality_of :left_order_count, greater_than_or_equal_to: 0, only_integer: true
  has_many :accounts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :brand_chains, -> { order("position ASC") }, dependent: :destroy
  has_many :base_branches, -> { order("position ASC") }, dependent: :destroy
  has_many :branches, -> { order("position ASC") }, dependent: :destroy
  has_many :online_branches, -> { where("branches.is_open = ?", true).order("position ASC")}, class_name: "Branch", foreign_key: :shop_id
  has_many :products, dependent: :destroy
  has_many :message_threads, dependent: :destroy
  has_many :messages, through: :message_threads
  has_many :carts, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :menus, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :materials, dependent: :destroy
  has_many :articles, through: :materials
  has_many :system_configs, dependent: :destroy
  has_many :all_users, class_name: "BaseUser"
  has_many :users, dependent: :destroy, class_name: "User"
  has_many :members, dependent: :destroy, class_name: "Member"
  has_many :phone_users, dependent: :destroy, class_name: "PhoneUser"
  has_many :credits_logs
  has_many :wallet_logs
  has_many :frozen_assets
  has_many :branch_comments, dependent: :destroy
  has_one :mail_setting, dependent: :destroy
  has_many :scrachpads, dependent: :destroy
  has_many :vip_levels, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :zones
  has_many :promotion_logs
  has_many :branch_types, dependent: :destroy
  has_many :branch_sliders, -> { order("position ASC") } ,dependent: :destroy
  has_many :form_elements, ->{where("type not in (?)", FormElementOption)}, dependent: :destroy
  has_one :theme
  has_many :trades
  has_many :weixinpay_feedbacks
  has_many :weixinpay_warnings
  has_many :sms_msgs, through: :branches
  has_many :currency_symbols
  has_one :tenpay
  has_one :mobile_alipay
  validates :max_sms_count, :numericality => { :greater_than_or_equal_to => 0}
  validates :award_credits, :numericality => { :greater_than => 0}, if: "self.award_credits_at_follow"
  validates :credit_for_each_money, :presence=>true, :numericality => { :greater_than => 0}, if: :support_credits_pay
  validate :credit_for_each_money_is_divide_by_100, if: :support_credits_pay
  validate :aid_is_exist, if: :aid?
  validates_length_of :support_link_name, :support_link, maximum:255
  validates_format_of :domain, with: /(^$)|(^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?)?$)/ix, allow_blank: true
  validates_uniqueness_of :domain, conditions: ->{where(validated_domain: true)}, allow_blank: true
  validates :foreign_currency_symbol, presence:true, if: :need_currency_sysmbol?
  after_update :change_accounts_login_ids

  has_many :service_sale_orders

  after_find do
    unless self.is_expired?
      if self.charge_method == CHARGE_METHOD_BY_ORDER_COUNT and left_order_count <= 0
        self.orders_use_up!
      elsif self.charge_method == CHARGE_METHOD_BY_TIME and self.expiration_time < Time.now
        self.expire_shop!
      end
    end
  end

  scope :shop_access_times_of_today, ->(shop){
    Impression.where("DATE_FORMAT(CONVERT_TZ(created_at,'+00:00','+08:00'), '%Y-%m-%d') = ? and impressionable_type = 'Shop' and impressionable_id = ? ", Time.now.localtime.strftime('%Y-%m-%d'), shop.id)}
  scope :distinct_users, ->{select('distinct(user_id)')}

  attr_accessor :state

  require 'carrierwave/orm/activerecord'
      mount_uploader :image, ShopImageUploader

  mount_uploader :qrcode, ShopQrcodeUploader
  validates :qrcode, file_size: {maximum: 1.megabytes.to_i}, if: :qrcode


  validates :image,
    :file_size => {
      :maximum => 1.megabytes.to_i
    }, if: :image?
  has_many :product_units, dependent: :destroy
  REPLY_CONTENT_TYPE_NEWS = "news"
  REPLY_CONTENT_TYPE_TEXT = "text"
  CHARGE_METHOD_BY_TIME = "by_time"
  CHARGE_METHOD_BY_ORDER_COUNT = "by_order_count"
  VERSION_MULTIPLE_BASE = "multiple_base_version"
  VERSION_SINGLE_VIP = "single_vip_version"
  VERSION_MULTIPLE_VIP = "multiple_vip_version"

  SHOP_VERSIONS = [VERSION_MULTIPLE_VIP, VERSION_SINGLE_VIP, VERSION_MULTIPLE_BASE]

  include Workflow
  workflow do
    state :trial do
      event :recharge_date, :transitions_to => :normally
      event :recharge_order, :transitions_to => :normally
      event :expire_shop, :transitions_to => :shop_expired
      event :orders_use_up, :transitions_to => :order_quantity_use_up
    end

    state :normally do
      event :recharge_date, :transitions_to => :normally
      event :recharge_order, :transitions_to => :normally
      event :expire_shop, :transitions_to => :shop_expired
      event :orders_use_up, :transitions_to => :order_quantity_use_up
    end

    state :shop_expired do
      event :recharge_date, :transitions_to => :normally
      event :recharge_order, :transitions_to => :normally
    end

    state :order_quantity_use_up do
      event :recharge_order, :transitions_to => :normally
    end
  end

  def agent
    Agent.find_by_aid(self.aid)
  end

  def need_validate_telephone
    if telephone_changed?
      !self.enable_foreign_currency
    end
  end

  def current_currency_symbol
    if self.enable_foreign_currency
      self.foreign_currency_symbol
    else
      DEFAULT_CURRENCY_SYMBOL
    end
  end


  def need_currency_sysmbol?
    self.enable_foreign_currency
  end

  REPLY_ORDERS_LIMIT_EIGHT = "eight"
  REPLY_ORDERS_OF_DAY = "day"
  REPLY_ORDERS_OF_WEEK = "week"
  REPLY_ORDERS_OF_MONTH = "month"
  def self.reply_orders_type_name(type)
    case type
    when REPLY_ORDERS_LIMIT_EIGHT
      "最近8个订单"
    when REPLY_ORDERS_OF_DAY
      "最近一天订单"
    when REPLY_ORDERS_OF_WEEK
      "最近一周订单"
    when REPLY_ORDERS_OF_MONTH
      "最近一个月订单"
    end
  end

  def self.reply_orders_type_array
    [
      [Shop.reply_orders_type_name(REPLY_ORDERS_LIMIT_EIGHT), REPLY_ORDERS_LIMIT_EIGHT],
      [Shop.reply_orders_type_name(REPLY_ORDERS_OF_DAY), REPLY_ORDERS_OF_DAY],
      [Shop.reply_orders_type_name(REPLY_ORDERS_OF_WEEK), REPLY_ORDERS_OF_WEEK],
      [Shop.reply_orders_type_name(REPLY_ORDERS_OF_MONTH), REPLY_ORDERS_OF_MONTH]
    ]
  end

  def get_current_reply_orders_type_name
    Shop.reply_orders_type_name(self.reply_num_of_orders)
  end

  def state=(new_value)
    self[:workflow_state] = new_value
  end

  def is_multipe_base_version?
    charge_method == CHARGE_METHOD_BY_ORDER_COUNT
  end

  def get_tenpay
    if self.tenpay.nil?
      self.create_tenpay
    end
    self.tenpay
  end

  def get_mobile_alipay
    if self.mobile_alipay.nil?
      self.create_mobile_alipay
    end
    self.mobile_alipay
  end

  def version
    if (charge_method == CHARGE_METHOD_BY_TIME) and (max_branches_count <= 1)
      VERSION_SINGLE_VIP
    elsif (charge_method == CHARGE_METHOD_BY_TIME) and (max_branches_count > 1)
      VERSION_MULTIPLE_VIP
    else
      VERSION_MULTIPLE_BASE
    end
  end

  def self.version_name(version)
    I18n.t "activerecord.attributes.shop.version.#{version}"
  end

  def version_name
    Shop.version_name(self.version)
  end

  def state
    self.current_state
  end

  def recharge_date(buyer_email, month_nums, service_sale_order)
    old_expiration_time = self.expiration_time
    max =  old_expiration_time > DateTime.now ? old_expiration_time + month_nums.months : DateTime.now + + month_nums.months
    self.update_attributes(:expiration_time=> max)
    log =  "#{buyer_email}为帐号#{self.name}续期服务#{month_nums}个月,账户过期时间由#{old_expiration_time.strftime("%Y-%m-%d %H:%M:%S")}续费至#{max.strftime("%Y-%m-%d %H:%M:%S")}"
    TransactionLog.create(:description=>log, :buyer_email=>buyer_email, :shop_id=> self.id, :service_sale_order => service_sale_order)
    Rails.logger.info(log)
  end

  def recharge_order(buyer_email,order_nums, service_sale_order)
    old_left_order_count = self.left_order_count
    self.increment!(:left_order_count, order_nums)
    log =  "#{buyer_email}为帐号#{self.name}充值订单数#{order_nums},剩余的订单数由#{old_left_order_count}修改为#{self.left_order_count}"
    TransactionLog.create(:description=>log, :buyer_email=>buyer_email, :shop_id=> self.id, :service_sale_order=>service_sale_order)
    Rails.logger.info(log)
  end

  def recharge_sms_msgs(buyer_email, sms_msg_nums,service_sale_order)
    old_max_sms_count = self.max_sms_count
    self.increment!(:max_sms_count, sms_msg_nums)
    log =  "#{buyer_email}为帐号#{self.name}充值短信数#{sms_msg_nums}, 累计充值短信数由#{old_max_sms_count}修改为#{max_sms_count}"
    TransactionLog.create(:description=>log, :buyer_email=>buyer_email, :shop_id=> self.id, :service_sale_order=>service_sale_order)
    Rails.logger.info(log)
  end

  def expire_shop
    Rails.logger.info "帐号'#{self.name}'到期"
  end

  def orders_use_up
    Rails.logger.info "帐号'#{self.name}'订单数量已使用完"
  end

  def begin
    Rails.logger.info "帐号'#{self.name}'恢复营业"
  end

  def is_expired?
    current_state == :shop_expired or current_state == :order_quantity_use_up
  end

  def branches_count
    branches.size
  end

  def get_mail_setting
    mail_setting = self.mail_setting
    if self.mail_setting.nil?
      mail_setting = self.create_mail_setting
    end
    mail_setting
  end
  def all_branches
    branches
  end

  def active_branches
    branches.where(:is_open=>true)
  end

  def default_reply_content_type_name
    if default_reply_content_type == REPLY_CONTENT_TYPE_NEWS
      "图文消息"
    elsif default_reply_content_type == REPLY_CONTENT_TYPE_TEXT
      "文字消息"
    end
  end


  def charge_method_name
    if charge_method == CHARGE_METHOD_BY_ORDER_COUNT
      "按订单数量计费"
    elsif charge_method == CHARGE_METHOD_BY_TIME
      "按服务时间计费"
    else
      logger.error "未知的计费方式：商户Id:#{id}"
      "未知的计费方式"
    end
  end

  def workflow_state_name
    self.class.shop_state_name_by_state(self.state)
  end

  def self.shop_state_name_by_state(state)
    I18n.t "activerecord.attributes.shop.workflow_state.#{state}"
  end

  def random_domain
    domains = REGEXDOMAIN.match self.domain
    domains = [Digest::MD5.hexdigest(self.created_at.to_s)[0,10], domains]
    domains.join "."
  end

  def validation_domain(server_host)
    result = `ping #{random_domain} -c 1`
    server = `ping #{server_host} -c 1`
    unless result.match(/1 received/) && server.match(/1 received/) && result.match(REGEXIP).to_s && server.match(REGEXIP).to_s && result.match(REGEXIP).to_s == server.match(REGEXIP).to_s
      return
    end
    self.validated_domain = true
    self.save
    self
  end

  before_save :domain_status
  before_validation :set_default

  def set_default
    self.left_order_count ||= 0
  end

  def domain_status
    self.validated_domain = false if self.domain_changed?
    true
  end

  private

  def aid_is_exist
    if agent.nil?
      self.errors.add(:aid, "不准确")
    end
  end

  def credit_for_each_money_is_divide_by_100
    unless credit_for_each_money % 100 == 0
      self.errors.add(:credit_for_each_money, "必须为100的倍数")
    end
  end

  def change_accounts_login_ids
    if slug_changed?
      self.accounts.each do|account|
        account.save!
      end
    end
  end
end
