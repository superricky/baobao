#encoding: utf-8
require 'csv'
include WechatUtils
class Order < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include WeixinPay
  CANCELED = 0
  WAIT_CONFIRMED = 1
  CONFIRMED = 2
  DELIVERING = 3
  DELIVERED = 4
  COMPLETED = 5
  STATES = [[I18n.t('order.state.canceled'), CANCELED],
    [I18n.t('order.state.wait_confirmed'), WAIT_CONFIRMED],
    [I18n.t('order.state.confirmed'), CONFIRMED],
    [I18n.t('order.state.delivering'), DELIVERING],
    [I18n.t('order.state.delivered'), DELIVERED],
    [I18n.t('order.state.completed'), COMPLETED]]

  ORDERTYPE_DELIVERY = "delivery"#外送
  ORDERTYPE_EAT_IN_HALL = "eat_in_hall"#堂吃
  ORDERTYPE_ORDER_SEAT = "order_seat"

  #CREDIT_PAYMENT_TYPE = "pay_by_credits"
  PAY_ON_RECEIVE_PAYMENT_TYPE = "pay_on_receive"
  PAY_BY_WEIXIN_TYPE = "pay_by_weixin"
  PAY_BY_TENPAY_TYPE = "pay_by_tenpay"
  PAY_BY_MOBILE_ALIPAY_TYPE = "pay_by_mobile_alipay"
  #WALLET_PAYMENT_TYPE = "pay_by_wallet"
  validates :pay_type, :inclusion => { :in => [
      PAY_ON_RECEIVE_PAYMENT_TYPE,
      PAY_BY_WEIXIN_TYPE,
      PAY_BY_TENPAY_TYPE,
      PAY_BY_MOBILE_ALIPAY_TYPE
      ] }

  validates :name, presence: true, length: {minimum:2}, if: "is_delivery? or is_order_seat?"
  validates :phone, presence:true, if: "is_delivery? or is_order_seat?"
  validates :phone, format: {with: VALID_PHONE_REGEX}, if: "need_validate_phone?"
  validates :address, presence: true, length: {minimum:3}, if: :is_delivery?
  #validates :delivery_time, presence: true, if: :is_delivery?
  validates :guest_num, presence: true, if: "is_eat_in_hall? or is_order_seat?"
  validates :desk_no , presence: true, if: :is_eat_in_hall?
  #validates :arrive_time, presence: true, if: :is_order_seat?
  has_many :order_items, dependent: :destroy
  has_one :scrachpad
  has_many :credits_logs
  has_many :frozen_assets
  has_many :form_contents
  accepts_nested_attributes_for :form_contents, allow_destroy: true
  accepts_nested_attributes_for :order_items, allow_destroy: true
  #积分支付部分
  validates :consume_credit, numericality: { greater_or_equal_than: 0 }
  #余额支付部分
  validates :consume_wallet, numericality: { greater_or_equal_than: 0 }
  #现金支付部分
  validates :cash_amount, numericality: { greater_or_equal_than: 0 }
  validates :amount, presence: true, numericality: { greater_or_equal_than: 0 }

  validate :validation_delivery_period, on: :create ,if: "branch.fixed_delivery_time"

  belongs_to :shop, counter_cache: true
  belongs_to :user, counter_cache: true
  belongs_to :branch, counter_cache: true
  belongs_to :delivery_zone
  has_many :wallet_logs
  has_one :trade, :foreign_key=>"out_trade_no"
  default_scope {order('created_at DESC')}
  after_create :after_create_order_callback
  after_create :update_validated_phones, if: :need_validate_code
  after_save :after_change_order_to_completed
  before_save :after_change_order_to_delivering
  after_save :after_change_order_to_canceled

  attr_accessor :validation_code
  validate :validate_validation_code, on: :create, if: :need_validate_code
  validate :validate_wallet, on: :create
  #validate :order_in_service_time, on: :create, if: :is_delivery?
  #validate :order_in_arrive_time, on: :create, if: :is_order_seat?
  validate :order_less_min_order_charge, on: :create, if: :is_delivery?

  validate :validate_quantity_less_than_stock, on: :create, if: 'branch.check_stock'

  scope :for_year, ->(year) { where("DATE_FORMAT(orders.created_at, '%Y') = ?", year)}
  scope :for_7_days, ->{where("created_at >=  ?", 7.days.ago.strftime("%Y-%m-%d"))}
  scope :for_n_days, ->(n) {where("created_at >=  ?", n.days.ago.strftime("%Y-%m-%d"))}
  scope :for_today, -> {where("DATE_FORMAT(orders.created_at, '%Y-%m-%d') = ?", Time.now.strftime("%Y-%m-%d"))}
  scope :since, ->(order_id) {where("id > ? ",  order_id) if order_id.present? }
  scope :before, ->(order_id) {where("id < ? ",  order_id) if order_id.present?}

  def open
  end
  def close
  end

  def validate_wallet
    if self.consume_wallet > 0 && user.wallet < self.consume_wallet
      self.errors[:base]  = "您的余额不足#{shop.current_currency_symbol}#{self.consume_wallet}"
    end
  end

  def branch_name
    Branch.with_deleted.find(self.branch_id).name
  end

  def validation_delivery_period
    select_delivery_period = branch.select_delivery_times.select do |delivery_time|
      "#{delivery_time.delivery_time_start.strftime("%H:%M")}~~#{delivery_time.delivery_time_end.strftime("%H:%M")}" == self.delivery_period
    end
    unless select_delivery_period.present?
      self.errors[:base] = "您现在不能选择#{self.delivery_period}这个时间段送餐"
    end
  end


  def validate_quantity_less_than_stock
    self.order_items.each do|order_item|
      if order_item.product.present? and (order_item.product.stock < order_item.quantity)
        self.errors[:base] = "#{order_item.product.name}库存不够，请返回重新修改购买的数量"
      end
    end
  end

  def send_order_to_wechat
    system_config = SystemConfig.get_send_order_system_config
    if system_config
      appId = system_config.appId
      appSecret = system_config.appSecret
      material = Material.new(
        :msg_type=>'news')
      material.articles.build({
        :title=>"#{self.branch.name}又有新的订单了",
        :description=> "#{self.order_detail}"
      })
      users = Account.order_receive_accounts(self.branch).map{|account| account.user}
      users.each do |user|
        begin
          send_custom_message(material, user.fake_user_name, appId, appSecret)
        rescue Exception => e
          Rails.logger.info e.message
        end
      end
    end
  end

  def is_first_order_of_user
    isFirstOrder = "该用户为首次下单"
    orders_belongs_to_user_and_branch = self.user.orders.where(branch: self.branch) rescue nil
    if (not orders_belongs_to_user_and_branch.nil? and not orders_belongs_to_user_and_branch.empty? and
         orders_belongs_to_user_and_branch.size > 1)
      isFirstOrder = "否"
    end
    isFirstOrder
  end

  def is_weixin_pay_type?
    self.pay_type == PAY_BY_WEIXIN_TYPE
  end

  def is_tenpay_type?
    self.pay_type == PAY_BY_TENPAY_TYPE
  end

  def is_mobile_alipay_type?
    self.pay_type == PAY_BY_MOBILE_ALIPAY_TYPE
  end

  def is_online_pay?
    [PAY_BY_WEIXIN_TYPE, PAY_BY_TENPAY_TYPE, PAY_BY_MOBILE_ALIPAY_TYPE].include? self.pay_type
  end

  def need_validate_phone?
    if self.shop.enable_foreign_currency
      return false
    elsif is_delivery? or is_order_seat?
      return true
    end
  end

  def deal_order_with_pay_type(cart)
    order_strategy = OrderStrategy.new
    delivery_fee = order_strategy.delivery_fee(cart, self.order_type, self.delivery_zone)
    if [PAY_ON_RECEIVE_PAYMENT_TYPE, PAY_BY_WEIXIN_TYPE, PAY_BY_TENPAY_TYPE, PAY_BY_MOBILE_ALIPAY_TYPE].include? self.pay_type
      if !order_strategy.is_valid_credits_consume?(cart, delivery_fee, consume_credit)
        self.errors[:consume_credit] = "积分支付的数额非法"
        return false
      end

      if !order_strategy.is_valid_wallet_consume?(cart, delivery_fee, consume_wallet)
        self.errors[:consume_wallet] = "余额支付的数额非法"
        return false
      end

      if !order_strategy.is_valid_credits_wallet_consume(cart, delivery_fee, consume_wallet, consume_credit)
        self.errors[:consume_wallet] = "积分支付和余额支付的总额非法"
        return false
      end

      self.cash_amount = order_strategy.cash_amount_after_paytype(cart, delivery_fee, consume_wallet, consume_credit)
      self.amount = order_strategy.cart_amount_after_discount(cart)+delivery_fee
      self.user = cart.user unless self.user
      self.shop = cart.shop
      self.credits = order_strategy.credits_total_return(cart, consume_credit)

      cart.line_items.each do|line_item|
        self.order_items.build(:name => line_item.product.name,
        :product => line_item.product,
        :product_unit => line_item.product.product_unit,
        :price=> line_item.product.price(user), :quantity => line_item.quantity)
      end if self.order_items.length == 0

      if delivery_fee > 0
        self.order_items.build(:name => I18n.t('delivery_fee'), :price=> delivery_fee, :quantity => 1)
      end
      return true
    end
    return false
  end

  def order_in_service_time
    unless self.branch.is_in_service_time?(self.delivery_time)
      self.errors[:delivery_time] = "必须在营业时间范围内"
    end
    unless Time.now + self.branch.min_order_time_gap.minutes <= self.delivery_time
      self.errors[:delivery_time] = "必须在当前时间#{self.branch.min_order_time_gap}分钟之后"
    end
  end

  def order_in_arrive_time
    unless self.branch.is_in_service_time?(self.arrive_time)
      self.errors[:arrive_time] = "必须在营业时间范围内"
    end
  end

  def self.to_csv(orders, options = {})
    CSV.generate(options) do |csv|
      csv << [ "订单编号", "用户名", "电话", "送货地址", "金额", "下单时间", "帐号", "商户", "订单类型", "备注"]
      orders.each do |order|
        csv << [order.id, order.name, order.phone, order.address, order.amount, order.created_at.strftime("%Y-%m-%d %H:%M:%S"), (order.shop.name rescue nil), (order.branch.name rescue nil), order.order_type_name, order.note]
      end
    end
  end

  def self.get_order_types(custom_ui_setting)
    order_delivery_btn_txt = CustomUiSetting.human_attribute_name(:order_delivery_btn)
    order_eat_in_hall_btn_txt = CustomUiSetting.human_attribute_name(:order_eat_in_hall_btn)
    order_order_seat_txt = CustomUiSetting.human_attribute_name(:order_order_seat)
    if custom_ui_setting.present?
      unless custom_ui_setting.order_delivery_btn.nil? or custom_ui_setting.order_delivery_btn.empty?
        order_delivery_btn_txt = custom_ui_setting.order_delivery_btn
      end

      unless custom_ui_setting.order_eat_in_hall_btn.nil? or custom_ui_setting.order_eat_in_hall_btn.empty?
        order_eat_in_hall_btn_txt = custom_ui_setting.order_eat_in_hall_btn
      end

      unless custom_ui_setting.order_order_seat.nil? or custom_ui_setting.order_order_seat.empty?
        order_order_seat_txt = custom_ui_setting.order_order_seat
      end
    end
    [[order_delivery_btn_txt, ORDERTYPE_DELIVERY],
    [order_eat_in_hall_btn_txt, ORDERTYPE_EAT_IN_HALL],
    [order_order_seat_txt, ORDERTYPE_ORDER_SEAT]]

  end

  def self.update_order_finished_after_1_day
    orders = Order.where("created_at <= :one_day_ago and state not in (:states)", one_day_ago: (Time.now - 1.day).to_s , states: [CANCELED, DELIVERED ,COMPLETED])
    orders.each do |order|
      order.state = DELIVERED
      order.save!
    end
  end

  def after_change_order_to_delivering
    if self.is_weixin_pay_type? && self.is_paid? && state_changed? && (state == Order::DELIVERING)
      delivery_product(self)
    end
  end

  def after_change_order_to_canceled
    if state_changed? && (state == Order::CANCELED)
      branch = self.branch
      shop = branch.shop
      begin
        CancelOrderWorker.perform_in(1.second, self.id)
        self.frozen_assets.each do |frozen_asset|
          if frozen_asset.is_credit_asset?
            self.user.increment!(:credits, frozen_asset.credits)
            order_strategy = OrderStrategy.new
            order_strategy.create_credits_log(self, CreditsLog::CREDITS_LOG_TYPE_PAY_ROLLBACK, frozen_asset.credits, nil, "订单#{self.id}积分支付回退")
            frozen_asset.destroy!
          end
          if frozen_asset.is_wallet_asset?
            self.user.increment!(:wallet, frozen_asset.amount)
            order_strategy = OrderStrategy.new
            order_strategy.create_wallet_log(self, WalletLog::WALLET_LOG_TYPE_ROLLBACK, nil, "订单#{self.id}余额回退")
            frozen_asset.destroy!
          end
        end
      end
    end
  end

  def after_change_order_to_completed
    begin
      if state_changed? && (state == Order::COMPLETED)
        self.branch.income += self.amount
        self.shop.income += self.amount
        order_strategy = OrderStrategy.new
        self.frozen_assets.each do |frozen_asset|
          if frozen_asset.is_credit_asset?
            self.branch.increment!(:credits_consume, frozen_asset.credits)
            self.shop.increment!(:credits_consume, frozen_asset.credits)
            order_strategy.create_credits_log(self, CreditsLog::CREDITS_LOG_TYPE_PAY_SUCCESS, frozen_asset.credits, nil, "订单#{self.id}积分支付成功")
            frozen_asset.destroy!
          end
          if frozen_asset.is_wallet_asset?
            self.branch.increment!(:wallet_consume, frozen_asset.amount)
            self.shop.increment!(:wallet_consume, frozen_asset.amount)
            order_strategy.create_wallet_log(self, WalletLog::WALLET_LOG_TYPE_SUCCESS, nil, "订单#{self.id}余额支付成功")
            frozen_asset.destroy!
          end
        end
        if self.credits > 0
          self.user.increment!(:credits, self.credits)
          self.branch.increment!(:credits_given, self.credits)
          self.shop.increment!(:credits_given, self.credits)
          order_strategy.create_credits_log(self, CreditsLog::CREDITS_LOG_TYPE_RECHARGE, self.credits, nil, "订单#{self.id}积分到帐")
        end

        if self.amount > 0
          self.user.increment!(:total_amount, self.amount)
        end
      end
    rescue => e
      logger.error e.backtrace.join("\n")
      raise ActiveRecord::Rollback
    end
  end

  def is_delivery?
    order_type == ORDERTYPE_DELIVERY
  end

  def self.order_types_array
    [ORDERTYPE_DELIVERY, ORDERTYPE_EAT_IN_HALL, ORDERTYPE_ORDER_SEAT]
  end

  def is_eat_in_hall?
    order_type == ORDERTYPE_EAT_IN_HALL
  end

  def is_order_seat?
    order_type == ORDERTYPE_ORDER_SEAT
  end

  def is_remind_order?
    if self.is_remind_order_state?
      self.last_remind_date.nil? || self.last_remind_date + 0.5.hour < DateTime.now
    end
  end

  def is_remind_order_state?
    [WAIT_CONFIRMED, CONFIRMED, DELIVERING].include?(self.state)
  end

  def allow_change_state_for_admin?
    case state
    when CANCELED
      []
    when WAIT_CONFIRMED
      [CANCELED,CONFIRMED,DELIVERING,DELIVERED,COMPLETED]
    when CONFIRMED
      [CANCELED,DELIVERING,DELIVERED,COMPLETED]
    when DELIVERING
      [CANCELED,DELIVERED,COMPLETED]
    when DELIVERED
      [CANCELED,COMPLETED]
    when COMPLETED
      []
    else
      []
    end
  end

  def self.allow_batch_change_state(state)
    case state.to_i
    when CANCELED
      []
    when WAIT_CONFIRMED
      [CANCELED,CONFIRMED,DELIVERING,DELIVERED,COMPLETED]
    when CONFIRMED
      [CANCELED,DELIVERING,DELIVERED,COMPLETED]
    when DELIVERING
      [CANCELED,DELIVERED,COMPLETED]
    when DELIVERED
      [CANCELED,COMPLETED]
    when COMPLETED
      []
    else
      []
    end
  end


  def allow_change_state_for_user?
    case state
    when CANCELED
      []
    when WAIT_CONFIRMED
      [CANCELED]
    when CONFIRMED
      []
    when DELIVERING
      []
    when DELIVERED
      []
    when COMPLETED
      []
    else
      []
    end
  end

  def order_type_name
    self.branch.present? ? Order.get_order_type_name_by(self.branch, self.order_type) : "未知"
  end

  def self.get_order_type_name_by(branch, order_type)
    custom_ui_setting = branch.get_custom_ui_setting
    case order_type
    when ORDERTYPE_DELIVERY
      custom_ui_setting.get_value(:order_delivery_btn) || CustomUiSetting.human_attribute_name(:order_delivery_btn)
    when ORDERTYPE_EAT_IN_HALL
      custom_ui_setting.get_value(:order_eat_in_hall_btn) || CustomUiSetting.human_attribute_name(:order_eat_in_hall_btn)
    when ORDERTYPE_ORDER_SEAT
      custom_ui_setting.get_value(:order_order_seat) || CustomUiSetting.human_attribute_name(:order_order_seat)
    else
      logger.error "unknow order_type in order(id:#{id})"
      "未知"
    end
  end

  def pay_type_name
    custom_ui_setting = self.branch.custom_ui_setting
    case pay_type
    when PAY_ON_RECEIVE_PAYMENT_TYPE
      custom_ui_setting.pay_on_receive.present? ? custom_ui_setting.pay_on_receive : CustomUiSetting.human_attribute_name(:pay_on_receive)
    when PAY_BY_WEIXIN_TYPE
      "微信支付"
    when PAY_BY_MOBILE_ALIPAY_TYPE
      "支付宝手机支付"
    when PAY_BY_TENPAY_TYPE
      "财付通支付"
    else
      logger.error "unknow pay_type in order(id:#{id})"
      "未知"
    end
  end

  def state_name
    Order::state_name(state)
  end

  def self.state_name(state)
    state_item = Order::get_state_item_by_state(state)
    if state_item.nil?
      raise "unknow state for order #{id}"
      I18n.t('order.state.unknown')
    else
      state_item[0]
    end
  end

  def self.get_state_item_by_state(state)
    unless state.nil?
      STATES.select{|state_item| state_item[1] == state}[0]
    end
  end

  def self.get_state_items_by_states(state_array)
    state_items = []
    if state_array.nil?
      return state_items
    end
    if state_array.kind_of?(Array)
      state_array.each do |state|
        state_items << get_state_item_by_state(state)
      end
      state_items
    else
      state_items << get_state_item_by_state(state_array)
    end
  end

  def deal_with_delivery
    order_strategy = OrderStrategy.new
    self.amount += order_strategy.delivery_fee(self.cart)
  end

  # after_save :hand_out_scrachpad_to_user
  # # after_save :send_message
  # private
  # def hand_out_scrachpad_to_user
  #   if self.branch.give_scratchpad_to(self.user, self)
  #     self.user.scrachpads.create(:valid_before=>self.branch.valid_before,
  #     :card_result => self.branch.generate_scrach_prize,
  #     :shop => self.shop,
  #     :order => self,
  #     :branch => self.branch)
  #   end
  # end



  def order_less_min_order_charge
    if self.branch.use_min_order_charge && self.amount <= self.branch.non_service_order_charge
      self.errors[:amount] = "低于最小起送金额#{self.branch.non_service_order_charge}元，无法下单"
      return
    end
  end
  def after_create_order_callback
    branch = self.branch
    shop = branch.shop
      begin
        if shop.charge_method == Shop::CHARGE_METHOD_BY_ORDER_COUNT
          shop.decrement(:left_order_count)
          shop.save!
        end
      rescue => se
        logger.error se.backtrace.join("\n")
        logger.error "Got error for shop #{shop.id}: order id #{self.id}, error info:#{se} "
        raise ActiveRecord::Rollback
      end

      begin
        if branch.charge_method == Branch::CHARGE_METHOD_BY_ORDER_COUNT
          branch.decrement(:left_order_count)
          branch.save!
        end
      rescue => se
        logger.error se.backtrace.join("\n")
        logger.error "Got error for branch #{branch.id}: order id #{id}, error info:#{se} "
        raise ActiveRecord::Rollback
      end

      begin
        TradeRel.where(:user_id => self.user_id, :branch_id=>self.branch_id).first_or_create unless self.is_a? OrderWebstore or self.is_a? PhoneOrder
      rescue => se
        logger.error se.backtrace.join("\n")
        logger.error "unable  to create trade rel between user #{self.user_id} and branch #{self.branch_id} for order #{self.id}, error info #{se}"
        raise ActiveRecord::Rollback
      end

      begin
        save_user_info
      rescue => se
        logger.error se.backtrace.join("\n")
        logger.error se.message
        raise ActiveRecord::Rollback
      end

      begin
        if self.branch.give_scratchpad_to(self.user, self) && !self.is_a?(PhoneOrder)
          self.user.scrachpads.create(:valid_before=>self.branch.valid_before,
          :card_result => self.branch.generate_scrach_prize,
          :shop => self.shop,
          :order => self,
          :branch => self.branch)
        end
      rescue => se
        logger.error se.backtrace.join("\n")
        logger.error se.message
        raise ActiveRecord::Rollback
      end

      begin
        if self.shop.use_credits && self.shop.support_credits_pay && consume_credit > 0
          self.user.decrement!(:credits, self.consume_credit)
          self.frozen_assets.create({
            :shop => self.shop,
            :branch => self.branch,
            :credits => self.consume_credit,
            :amount => nil,
            :frozen_type => FrozenAsset::FROZEN_CREDITS,
            :user => self.user})
          order_strategy = OrderStrategy.new
          order_strategy.create_credits_log(self, CreditsLog::CREDITS_LOG_TYPE_PAY, consume_credit, nil, "订单#{self.id}使用积分支付")
        end
      rescue => se
        logger.error se.backtrace.join("\n")
        logger.error se.message
        raise ActiveRecord::Rollback
      end

      begin
        if self.shop.support_wallet_pay && consume_wallet > 0
          self.user.decrement!(:wallet, self.consume_wallet)
          self.frozen_assets.create({
            :shop => self.shop,
            :branch => self.branch,
            :credits => nil,
            :amount => self.consume_wallet,
            :frozen_type => FrozenAsset::FROZEN_WALLET,
            :user => self.user})
          order_strategy = OrderStrategy.new
          order_strategy.create_wallet_log(self, WalletLog::WALLET_LOG_TYPE_PAY, nil, "订单#{self.id}使用余额支付")
        end
      rescue => se
        logger.error se.backtrace.join("\n")
        logger.error se.message
        raise ActiveRecord::Rollback
      end
  end

  def save_user_info
    user = self.user
    need_save = false
    if user.phone.nil? or user.phone.empty?
      user.phone = self.phone
      need_save = true
    end

    if user.default_address.nil? or user.default_address.empty?
      user.default_address = self.address
      need_save = true
    end

    if user.name.nil? or user.name.empty?
      user.name = self.name
      need_save = true
    end

    if need_save
    user.save!
    end
  end

  def update_validated_phones
    if self.user.validated_phones.find_by_phone(self.phone).present?
      return
    else
      self.user.validated_phones.create(:phone => self.phone)
    end
  end

  def need_validate_code
    self.branch.support_validation? and (is_delivery? or is_order_seat?)
  end

  def validate_validation_code
    if self.user.validated_phones.find_by_phone(self.phone).present?
      return
    end

    if self.user.get_validation_code.code == self.validation_code
      return
    end

    if self.validation_code.nil? or self.validation_code.empty?
      self.errors[:base] = "验证码不能为空"
    else
      self.errors[:base] = "短信验证码不正确"
    end
  end

  def pay_state_name
    self.is_paid? ? '已支付' : '未支付'
  end

  def order_detail
    detail = "订单编号：#{self.id}
下单方式:#{self.order_type_name}
订购时间：#{self.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S')}"
    if is_delivery?
      detail += "
姓名：#{name}
电话：#{phone}"
      detail += "
配送区域：#{self.delivery_zone.zone_name}" if self.delivery_zone
      detail += "
配送地址：#{self.address}"

      if self.delivery_time
          detail += "
配送时间：#{self.delivery_time.strftime('%Y-%m-%d %H:%M')}"
      end

      if self.form_contents.present?
        self.form_contents.each do |record|
          detail += "
#{record.label}：#{record.content}"
        end
      end
    elsif is_eat_in_hall?
      detail += "
桌号:#{self.desk_no}
人数：#{self.guest_num}
"

    elsif is_order_seat?
      detail += "
姓名：#{self.name}
电话：#{self.phone}
人数：#{self.guest_num}
"
      if self.arrive_time.present?
        detail +="到店时间：#{self.arrive_time.strftime('%Y-%m-%d %H:%M')}"
      end
    end
      detail += "
商品名称      单价  数量  小计
－－－－－－－－－－－－－－－－
"
    self.order_items.each do |order_item|
      detail +=
"#{order_item.name.ljust(14-order_item.name.length)}#{('%.2f' % order_item.price).ljust(5)}#{order_item.quantity.to_s.rjust(3)}#{('%.2f' % (order_item.price * order_item.quantity)).rjust(7)}
"
    end
    detail += "
备注：#{note}
"
    detail += "－－－－－－－－－－－－－－－－
合计：#{('%.2f' % self.amount)}元"
    if self.consume_credit > 0
      detail += "
积分抵扣 :#{self.consume_credit}积分"
    end
    if self.consume_wallet > 0
      detail += "
余额抵扣 : -#{('%.2f' % (self.consume_wallet))}元"
    end
    detail += "
实付金额 : #{('%.2f' % (self.cash_amount || 0))}元
"
    detail += "
支付方式：#{self.pay_type_name}"
    if self.is_weixin_pay_type?
      detail += "
支付状态：#{self.is_paid? ? '已支付' : '未支付'}"
    end
    detail
  end
end
