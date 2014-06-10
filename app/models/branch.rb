#encoding:utf-8
require 'file_size_validator'
class Branch < BaseBranch #ActiveRecord::Base
  after_destroy :clean_up
  is_impressionable

  PRODUCT_LIST_STYLE_THUMB = 'thumb'
  PRODUCT_LIST_STYLE_TXT = 'txt'
  PRODUCT_LIST_STYLE_THUMB_NAME = I18n.t('product_list_style.thumb')
  PRODUCT_LIST_STYLE_TXT_NAME = I18n.t('product_list_style.txt')
  PRODUCT_LIST_STYLES = [[PRODUCT_LIST_STYLE_THUMB_NAME,PRODUCT_LIST_STYLE_THUMB],
    [PRODUCT_LIST_STYLE_TXT_NAME, PRODUCT_LIST_STYLE_TXT]]
  has_many :orders
  has_many :products, -> { order("position ASC") }, dependent: :destroy
  has_many :categories, -> { order("position ASC") } , dependent: :destroy
  has_many :products_online, -> {where("products.down = ?", false)}, class_name: "Product"
  has_many :tags, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_and_belongs_to_many :accounts
  has_many :printers, dependent: :destroy
  has_many :credits_logs
  has_one :custom_ui_setting, dependent: :destroy
  belongs_to :branch_type, counter_cache: true
  has_many :wallet_logs
  has_many :frozen_assets
  has_many :trade_rels
  has_many :delivery_zones, dependent: :destroy
  accepts_nested_attributes_for :delivery_zones, allow_destroy: true
  has_many :branch_comments, dependent: :destroy
  has_many :users, through: :trade_rels
  has_many :scrachpads, dependent: :destroy
  has_many :product_sliders, -> { order("position ASC") }, dependent: :destroy
  has_and_belongs_to_many :zones
  belongs_to :brand_chain, counter_cache: true
  has_many :awards
  has_many :form_elements, ->{where("form_element_id is null or form_element_id = 0")}, dependent: :destroy
  has_many :trades

  validate :validate_supported_order_types
  validates :sms_to, presence: true, format:{with: VALID_PHONE_REGEX}, if: :use_sms
  validates :telephone, format:{with: VALID_PHONE_TEL_REGEX}, :allow_blank=>true, if: :need_validate_telephone
  validates :latitude, :longitude, presence: true
  validates :address, presence: true, length:{minimum:5}
  validates :zip_code, format:{with: /\A((\d{6})|(\d{4}))\Z/i}, :allow_blank=>true
  validates :expiration_time, presence: true
  validates :min_order_charge, :non_service_order_charge, :delivery_radius, presence: true, if: :use_min_order_charge
  validates :first_prize_possibility, :second_prize_possibility, :third_prize_possibility, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100 }
  validates :min_charge_for_scratch, presence: true, if: :use_scrachpad?
  validates :first_prize, presence: true, if: :has_first_prize?
  validates :second_prize, presence: true, if: :has_second_prize?
  validates :third_prize, presence: true, if: :has_third_prize?
  validates :delivery_zones, :length => { :minimum => 1}, if: :use_min_order_charge
  validate  :prize_possibility
  validate :validate_supported_scratchpad_order_types, if: :use_scrachpad
  validate :validate_supported_scratchpad_order_types, if: :use_sms
  validates :max_sms_count, :numericality => { :greater_than_or_equal_to => 0}
  validates :product_list_style, :inclusion => { :in => [PRODUCT_LIST_STYLE_THUMB, PRODUCT_LIST_STYLE_TXT] }
  validates_numericality_of :delivery_radius, :greater_than => 0.0, :less_than => 10000.0

  scope :branch_access_times_of_week, ->(branch_ids){ Impression.where(:created_at=> 7.days.ago..Time.now, :impressionable_type => 'BaseBranch', :impressionable_id => branch_ids)}
  accepts_nested_attributes_for :awards, :allow_destroy => true

  has_many :service_periods
  accepts_nested_attributes_for :service_periods, :allow_destroy => true
  validates_associated :service_periods
  validates :service_periods, :length => { :minimum => 1}, if: :enabled_verify_service_periods

  has_many :delivery_times
  accepts_nested_attributes_for :delivery_times, :allow_destroy => true
  validates_associated :delivery_times
  validates :delivery_times, :length => { :minimum => 1}, if: :fixed_delivery_time

  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  has_many :product_units, dependent: :destroy
  has_many :sms_msgs, dependent: :destroy


  #has_one :system_config, dependent: :destroy
  CHARGE_METHOD_BY_TIME = "by_time"
  CHARGE_METHOD_BY_ORDER_COUNT = "by_order_count"

  public

  def self.active_branches_by_shop_brand_chains(shop)
    where(is_open: true, brand_chain_id: shop.brand_chain_ids)
  end

  def self.active_branches_with_brand_chains_by_shop(shop)
    branches = active_branches_by_shop_brand_chains(shop)
    branches += shop.active_branches
    branches.uniq
  end

  def self.active_branches_by_shop_brand_chains_and_join_branch_types(shop, branch_type)
    branches = active_branches_by_shop_brand_chains(shop).joins(:branch_type).where("branch_types.id" => branch_type).group("branches.id")
    branches += shop.active_branches.joins(:branch_type).where("branch_types.id" => branch_type).group("branches.id")
    branches.uniq
  end

  def self.active_branches_by_shop_brand_chains_and_join_zones(shop, zone)
    branches = active_branches_by_shop_brand_chains(shop).joins(:zones).where("zones.id"=>zone).group("branches.id")
    branches += shop.active_branches.joins(:zones).where("zones.id"=>zone).group("branches.id")
    branches.uniq
  end

  def need_validate_telephone
    if telephone_changed?
      !shop.enable_foreign_currency
    end
  end

  def self.order_access_times_desc(branch_ids)
    Branch.branch_access_times_of_week(branch_ids).group(:impressionable_id).count.sort_by{|key,value| value}.reverse
  end

  def is_charge_by_order
    charge_method == CHARGE_METHOD_BY_ORDER_COUNT
  end

  def is_charge_by_time
    charge_method == CHARGE_METHOD_BY_TIME
  end

  def is_expired?
    if is_charge_by_order
      left_order_count <= 0
    elsif is_charge_by_time
      expiration_time < Time.now
    else
      true
    end
  end

  def has_delivery_type?
    self.supported_order_types.include?("delivery")
  end

  def product_list_style_name
    if product_list_style == PRODUCT_LIST_STYLE_TXT
      PRODUCT_LIST_STYLE_TXT_NAME
    elsif product_list_style == PRODUCT_LIST_STYLE_THUMB
      PRODUCT_LIST_STYLE_THUMB_NAME
    end
  end

  def check_stock_name
    self.check_stock ? "检查库存" : "不检查库存"
  end

  def is_on_service?
    now = Time.now
    is_in_service_time?(now)
  end

  def get_service_periods
    if self.service_periods.present?
      self.service_periods.map do |service_period|
        "#{service_period.service_period_start.strftime("%H:%M")}~~#{service_period.service_period_end.strftime("%H:%M")}"
      end
    else
      ["24小时服务"]
    end
  end

  def select_delivery_times
    now_time = Branch::time_since_beginning_of_day(Time.now)
    self.delivery_times.select do |delivery_time|
      now_time.to_i <= (Branch::time_since_beginning_of_day(delivery_time.delivery_time_start) - delivery_time.time_advance.minutes.to_i)
    end
  end

  def is_in_service_time?(now)
    self.service_periods.each do |service_period|
      if service_period.is_in_service_time?(now)
        return true
      end
    end
    return false
  end

  def self.time_since_beginning_of_day(the_time)
    the_time.to_i - the_time.beginning_of_day.to_i
  end

  def split_supported_order_types
    unless supported_order_types.nil?
      supported_order_types.split(",")
    else
      []
    end
  end

  def split_supported_scratchpad_order_types
    unless supported_scratchpad_order_types.nil?
      supported_scratchpad_order_types.split(/,/)
    else
      []
    end
  end

  def split_supported_send_sms_order_types
    unless supported_send_sms_order_types.nil?
      supported_send_sms_order_types.split(/,/)
    else
      []
    end
  end

  def supported_order_types_array
    supported_order_types_array_with_ui(get_custom_ui_setting)
  end

  def supported_order_types_array_with_ui(custom_ui_setting)
    Order::get_order_types(custom_ui_setting).select{|order_type| self.split_supported_order_types.include? order_type[1]}
  end

  def supported_pay_types_array_with_ui_setting(system_config, custom_ui_setting, use_tenpay, use_mobile_alipay)
    if custom_ui_setting.nil?
      custom_ui_setting = self.create_custom_ui_setting
    end
    pay_types = []
    if system_config.support_weixin_pay?
      pay_types << ['微信支付', Order::PAY_BY_WEIXIN_TYPE]
    end
    if use_mobile_alipay
      pay_types << ['支付宝手机支付', Order::PAY_BY_MOBILE_ALIPAY_TYPE]
    end
    if use_tenpay
      pay_types << ['财付通支付', Order::PAY_BY_TENPAY_TYPE]
    end

    pay_types << [supported_pay_type_with_ui(custom_ui_setting, Order::PAY_ON_RECEIVE_PAYMENT_TYPE), Order::PAY_ON_RECEIVE_PAYMENT_TYPE]
    pay_types
  end

  def supported_pay_type_with_ui(custom_ui_setting, type)
    if custom_ui_setting.nil?
      custom_ui_setting = self.create_custom_ui_setting
    end
    custom_ui_setting.get_value(type)
  end

  def supported_dikou_types_array
    supported_dikou_types_array_with_ui(get_custom_ui_setting)
  end

  def supported_dikou_types_array_with_ui(custom_ui_setting)
    supported_dikou_types_array_with_ui_and_shop(custom_ui_setting, self.shop)
  end

  def supported_dikou_types_array_with_ui_and_shop(custom_ui_setting, shop)
    if custom_ui_setting.nil?
      custom_ui_setting = self.create_custom_ui_setting
    end
    results = []
    if shop.support_wallet_pay?
      results << [custom_ui_setting.get_value(:pay_by_wallet), 'pay_by_wallet']
    end
    if shop.support_credits_pay?
      results << [ custom_ui_setting.get_value(:pay_by_credits), 'pay_by_credits']
    end
    results
  end

  def supported_order_types_name
    self.supported_order_types_array.map{|order_type| order_type[0]}.join(",")
  end

  def supported_send_sms_order_types_name
    Order::get_order_types(self.custom_ui_setting).select{|order_type| self.split_supported_send_sms_order_types.include? order_type[1]}.map{|order_type| order_type[0]}.join(",")
  end

  def supported_scratchpad_order_types_name
    Order::get_order_types(get_custom_ui_setting).select{|order_type| self.split_supported_scratchpad_order_types.include? order_type[1]}.map{|order_type| order_type[0]}.join(",")
  end

  def charge_method_name
    if is_charge_by_order
      "按订单数量计费"
    elsif is_charge_by_time
      "按服务时间计费"
    else
      logger.error "未知的计费方式：商户Id:#{id}"
      "未知的计费方式"
    end
  end

  def get_custom_ui_setting
    if self.custom_ui_setting.nil?
      self.create_custom_ui_setting
    else
      self.custom_ui_setting
    end
  end

  def support_validation?
     support_validation_with_shop?(self.shop)
  end

  def support_validation_with_shop?(shop)
     shop.use_sms_validation and self.use_sms_validation and (shop.max_sms_count >= self.sms_msgs_count) and
     (self.max_sms_count >= self.sms_msgs_count)
  end

  def generate_scrach_prize
    rand = Random.rand(1..100)
    logger.info "rand code is #{rand}"
    if rand <= self.first_prize_possibility
      "一等奖"
    elsif rand <= (self.first_prize_possibility + self.second_prize_possibility)
      "二等奖"
    elsif rand <= (self.first_prize_possibility + self.second_prize_possibility+self.third_prize_possibility)
      "三等奖"
    else
      "谢谢参与"
    end
  end

  def self.copy_products_to_branch(branches, products)
    skiped_product_msgs = []
    branches.each do |branch|
      products.each do|product|
        new_product = branch.products.where(:name => product.name).first
        if new_product.nil?
          new_product = branch.products.build(
            :name => product.name,
            :shop => branch.shop,
            :description => product.description,
            :price => product.original_price,
            :stock => product.stock,
            :product_unit => product.product_unit,
            :pic => product.pic,
            :tag => (branch.tags.find_or_create_by(name: product.tag.name) rescue nil),
            :image =>product.image
          )
          product.categories.each do |category|
            new_product.categories << branch.categories.find_or_create_by(name: category.name)
          end
          new_product.save!
        else
          skiped_product_msgs << "商户#{branch.name}中已经存在与产品\"#{product.name}\"同名产品,跳过拷贝"
        end
      end
    end
    skiped_product_msgs
  end

  def has_first_prize?
    self.use_scrachpad && (((self.first_prize_possibility||0) > 0)||has_second_prize?||has_third_prize?)
  end

  def has_second_prize?
    self.use_scrachpad && (((self.second_prize_possibility||0) > 0)||has_third_prize?)
  end

  def has_third_prize?
    self.use_scrachpad && ((self.third_prize_possibility||0) > 0)
  end

  def give_scratchpad_to(user, order)
    user.is_a?(User) && self.use_scrachpad and (Time.now <  self.valid_before) and
      (order.amount >= self.min_charge_for_scratch) and
      (split_supported_scratchpad_order_types.include? order.order_type) and
      (user.scrachpads.where("branch_id = ? and DATE_FORMAT(created_at, '%Y-%m-%d') = ?", self.id, Time.now.strftime("%Y-%m-%d")).size < self.max_scratch_times_in_day)
  end

  def got_scratchpad_condition
    if self.use_scrachpad and (Time.now <  self.valid_before)
      "单笔消费满#{"%0.2f" % self.min_charge_for_scratch}元且使用(#{supported_scratchpad_order_types_name})中任意一种下单方式进行下单，当日内前#{self.max_scratch_times_in_day}次下单均可获得刮刮奖"
    else
      nil
    end
  end

  def clean_up
    promotions_to_destroy = []
    self.promotions.each do |promotion|
      if promotion.shop.nil?
        promotions_to_destroy << promotion
      end
    end
    unless promotions_to_destroy
      promotions_to_destroy.destroy_all
    end
  end


  def validate_supported_order_types
    order_types = self.split_supported_order_types
    if order_types.size == 0
      self.errors[:supported_order_types] = "至少需要选择一种下单方式"
      return
    end

    order_types.each do |order_type|
      if Order::order_types_array.index(order_type).nil?
        self.errors[:supported_order_types] = "非法的下单方式"
        return
      end
    end
  end

  def validate_supported_scratchpad_order_types
    scratchpad_order_types = self.split_supported_scratchpad_order_types()
    if scratchpad_order_types.size == 0
      self.errors[:supported_scratchpad_order_types] = "至少需要选择一种支持刮刮卡活动的方式"
      return
    end

    scratchpad_order_types.each do |scratchpad_order_type|
      if Order::order_types_array.index(scratchpad_order_type).nil?
        self.errors[:supported_scratchpad_order_types] = "非法的刮刮卡活动方式"
        return
      end
    end
  end

  def validate_supported_scratchpad_order_types
    supported_send_sms_order_types = self.split_supported_send_sms_order_types()
    if supported_send_sms_order_types.size == 0
      self.errors[:supported_send_sms_order_types] = "至少需要选择一种发送短信的方式"
      return
    end

    supported_send_sms_order_types.each do |supported_send_sms_order_type|
      if Order::order_types_array.index(supported_send_sms_order_type).nil?
        self.errors[:supported_scratchpad_order_types] = "非法的发送短信的方式"
        return
      end
    end
  end


  def prize_possibility
    if ((self.first_prize_possibility+self.second_prize_possibility+self.third_prize_possibility) > 100)
      self.errors[:use_scrachpad] << "一二三等奖得奖概率之和不能大于100%"
    end
  end

end
