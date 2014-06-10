#encoding: utf-8
require 'bcrypt'
class BaseUser < ActiveRecord::Base
  include BCrypt
  has_many :orders, foreign_key: :user_id
  has_many :credits_logs, foreign_key: :user_id
  has_many :wallet_logs, foreign_key: :user_id

  validates :vip_no, presence: true, if: :vip_level
  validates :vip_no, uniqueness: {:scope=>:shop_id}, :allow_blank => true, :allow_nil => true
  belongs_to :vip_level, counter_cache: true
  validates :vip_level, presence: true, if: :vip_no?

  scope :appling_vips, -> { where(:is_apply_vip_user => true) }

  scope :wechat_users, -> {where(type: "User")}
  scope :phone_users, -> {where(type: "PhoneUser")}
  scope :members, -> {where(type: "Member")}

  attr_accessor :pay_password
  before_validation :hash_pay_password
  validates :pay_password, :length => {:within => 4..20}, :allow_blank => true
  validates :pay_password_hash, presence: true, if: "vip_no? or is_apply_vip_user?"
  scope :for_year, ->(year) { where("DATE_FORMAT(base_users.created_at, '%Y') = ?", year)}
  default_scope {order('updated_at DESC')}

  def authenticate(password)
    if Password.new(self.pay_password_hash) == password
      self
    else
      nil
    end
  end

  def hash_pay_password
    if self.vip_no.present?
      if pay_password.present?
        self.pay_password_hash = Password.create(pay_password, :cost => 5)
      end
    elsif self.is_apply_vip_user?
      self.pay_password_hash = Password.create(pay_password, :cost => 5)
    else
      self.pay_password_hash = nil
    end
  end

  def is_vip?
    self.vip_no.present?
  end

  def get_sent_validation_code_times_in_today
    if self.last_sent_validation_code_time.present? and
      (Time.now.strftime("%Y-%m-%d") ==self.last_sent_validation_code_time.strftime("%Y-%m-%d"))
      self.sent_validation_code_times_in_today||0
    else
      0
    end
  end

  def user_type_name
    case self.type
    when "User"
      "微信用户"
    when "PhoneUser"
      "电话下单用户"
    when "Member"
      "PC端用户"
    end
  end

  ransacker :vip, :formatter => proc {|v| v } do |parent|
    parent.table[:vip_no]
  end
end