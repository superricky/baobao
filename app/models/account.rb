#encoding: utf-8
class Account < ActiveRecord::Base
  rolify
  ACCOUNTYPE_SYSTEM_ADMIN = 'system_admin'
  ACCOUNTYPE_SHOP_BOSS = 'boss'
  ACCOUNTYPE_SHOP_WORKER = 'worker'

  devise :database_authenticatable, :registerable, :lockable,
       :recoverable, :rememberable, :trackable, :confirmable, :validatable, :authentication_keys => [:login]

  ADMINTYPES = [[I18n.t('system_admin'), ACCOUNTYPE_SYSTEM_ADMIN],
    [I18n.t('boss'), ACCOUNTYPE_SHOP_BOSS],
    [I18n.t('worker'), ACCOUNTYPE_SHOP_WORKER] ]

  # has_secure_password
  before_save { |account| account.email = email.downcase }
  has_many :post_threads
  # before_save :create_remember_token
  has_many :api_keys, as: :owner
  has_many :push_regs, as: :binder

  validates :name, length: {maximum:50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :login_id, presence: true, uniqueness: { case_sensitive: false},format:{with:/\A[a-zA-Z][a-zA-Z0-9]{3,}\Z/},length: {minimum:4}, :on => :create
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX},
        uniqueness: { case_sensitive: false}
  validates :password, presence: true, length: {minimum:8},format:{with:/\A[_a-zA-Z0-9]{8,}\Z/}, on: :create
  validates :password_confirmation, presence: true, on: :create
  belongs_to :shop, counter_cache: true
  validates :shop, presence: true, unless: :is_admin?
  accepts_nested_attributes_for :shop
  validates :phone, presence: true ,uniqueness: {:scope=>:shop_id}
  validates :phone, format: {with: VALID_PHONE_TEL_REGEX}, if: :need_validate_phone
  has_and_belongs_to_many :branches
  belongs_to :user

  before_save :change_login_id, if: :need_change_login_id

  scope :worker_accounts, -> {select{|account| account.is_worker?}}

  attr_accessor :login
  attr_accessor :role
  attr_accessor :captcha
  attr_accessor :account_role

  attr_accessor :captcha_valid
  validate :check_captcha_valid, on: :create
  def check_captcha_valid
    if captcha_valid == false
      self.errors.add(:captcha, "不正确")
    end
  end

  def self.order_receive_accounts(branch)
    workers = branch.accounts.where.not(user_id: nil)
    bosses = branch.shop.accounts.select{|account| account.is_boss? && account.user.present? }
    workers | bosses
  end

  def need_validate_phone
    if phone_changed?
      !shop.enable_foreign_currency
    end
  end

  def self.find_for_authentication(conditions)
    account = super
    if account.nil?
      return nil
    end
    account
  end

  def is_admin?
    self.has_role? ACCOUNTYPE_SYSTEM_ADMIN
  end

  def is_boss?
    self.has_role? ACCOUNTYPE_SHOP_BOSS
  end

  def is_worker?
    self.has_role? ACCOUNTYPE_SHOP_WORKER
  end

  def role_name
    I18n.t(account_role)
  end

  def belongs_to?(branch_val)
    branches.include? branch_val
  end

  def account_role
    self.roles.first.name rescue nil
  end

  def role=(role)
    self.account_add_role(role)
  end

  def account_add_role(add_role)
    roles = self.roles
    roles.each do |role|
      self.remove_role role.name
    end
    self.add_role add_role
  end

  def self.to_csv(accounts, options)
    CSV.generate(options) do |csv|
      csv << [ "点账号名称", "短称", "手机", "姓名", "邮箱", "是否为代理客户","注册时间", "过期时间或剩余订单数"]
      accounts.each do |account|
        shop = account.shop
        is_charge_by_time = !shop.is_multipe_base_version?
        csv << [shop.name, shop.slug, account.phone, account.name, account.email, shop.aid.present? ? "是": "否", shop.created_at.strftime("%Y-%m-%d"), is_charge_by_time ? shop.expiration_time.strftime("%Y-%m-%d") : shop.left_order_count]
      end
    end
  end


  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(login_id) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def change_login_id
    login_id_str = self.login_id.split(":").last
    if login_id_str == shop.slug
      self.login_id = login_id_str
    else
      self.login_id = "#{shop.slug}:#{login_id_str}"
    end
  end

  private
    def need_change_login_id
      self.shop.present? and (self.login_id != self.shop.slug)
    end



end
