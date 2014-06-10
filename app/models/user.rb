#encoding: utf-8
require 'bcrypt'
class User < BaseUser
  include BCrypt
  has_many :api_keys, as: :owner
  has_one :message_thread, dependent: :destroy
  validates :fake_user_name, presence:true, uniqueness:{:scope=>:shop_id}
  validates :phone, presence:true, format: {with: VALID_PHONE_REGEX}, :on => :update, :allow_blank => true, unless: "shop.enable_foreign_currency"
  validates :email_address, format: {with: VALID_EMAIL_ADDRESS_REGEX }, :on => :update, :allow_blank => true
  validates :default_address, presence: true, length: {minimum:3},:allow_blank => true, :on => :update
  belongs_to :shop, counter_cache: true
  has_many :carts, dependent: :destroy
  has_one :validation_code, foreign_key: 'code_owner_id', dependent: :destroy
  has_many :validated_phones, foreign_key: "phone_owner_id", dependent: :destroy
  has_many :sms_msgs, foreign_key: "sms_msg_owner_id"

  has_and_belongs_to_many :branches, join_table: 'trade_rels'
  has_many :scrachpads, dependent: :destroy
  belongs_to :generalize_user, class_name: "User"
  has_many :audiences, class_name: "User", foreign_key: "generalize_user_id", counter_cache: :audiences_count

  validates :credits, :numericality => { :greater_than_or_equal_to => 0}
  validates :total_amount, :numericality => { :greater_than_or_equal_to => 0}
  validates :scene_id, uniqueness: {:scope => :shop_id}, unless: "scene_id.nil?"
  after_update :after_update_total_amount_callback, if: "total_amount_changed? and is_vip?"


  def get_orders_by_reply_orders_type
    case self.shop.reply_num_of_orders
    when Shop::REPLY_ORDERS_LIMIT_EIGHT
      self.orders.limit(8)
    when Shop::REPLY_ORDERS_OF_DAY
      self.orders.where("created_at >= ?", Time.now - 1.day)
    when Shop::REPLY_ORDERS_OF_WEEK
      self.orders.where("created_at >= ?", Time.now - 1.week)
    when Shop::REPLY_ORDERS_OF_MONTH
      self.orders.where("created_at >= ?", Time.now - 1.month)
    else
      self.orders
    end
  end

  def user_mark
    "ID(#{self.id}) - #{self.name.presence || self.fake_user_name}"
  end

  def self.get_binding_users
    system_config = SystemConfig.get_send_order_system_config
    if system_config
      users = system_config.shop.users
    end
  end

  def system_config
    shop.system_configs.find_by_my_fake_id(self.my_fake_id) rescue nil
  end

  def self.get_max_scene_id_value(shop)
    shop.users.where.not(scene_id: nil).order("scene_id DESC").first.scene_id rescue 0
  end

  def create_credits_log(credits_log_type, credits, note=nil)
    self.credits_logs.create!({
      :shop=>self.shop,
      :credit_log_type => credits_log_type,
      :credits => credits,
      :note => note,
      :shop_credits_given_after =>self.shop.credits_given,
      :shop_credits_consume_after => self.shop.credits_consume,
      :branch_credits_given_after => (branch.credits_given rescue nil ),
      :branch_credits_consume_after => (branch.credits_consume rescue nil),
      :user_credits_balance_after => (self.user.credits rescue nil)
      })
  end

  def set_user_wechat_info
    system_config = self.shop.system_configs.find_by(my_fake_id: self.my_fake_id)
    if system_config
      user_wechat_info = Message.user_info(self.fake_user_name, system_config)
      nickname = user_wechat_info["nickname"]
      headimgurl = user_wechat_info["headimgurl"]
      self.update_attributes(nickname: nickname, headimgurl: headimgurl)
    end
  end

  def self.get_user_info_by_access_taken(openid, access_taken)
    conn = Message.get_faraday('https://api.weixin.qq.com')
    nickname_params = {
      access_token: access_taken,
      openid: openid,
    }
    response = conn.post do |req|
      req.url "/cgi-bin/user/info"
      req.body = nickname_params.to_param
    end
    JSON.parse(response.body)
  end

  def recharge(account, recharge_amount)
    recharge_amount = recharge_amount.to_f
    if(recharge_amount <= 0)
      self.errors[:recharge_amount] = "充值金额必须大于0"
      return false
    end
    if account==nil
      raise Exception.new("account can not be nil")
    end
    User.transaction do
        self.increment!(:wallet, recharge_amount)
        self.shop.increment!(:wallet_given, recharge_amount)

        shop_wallet_given_after = shop.wallet_given
        shop_wallet_consume_after = shop.wallet_consume
        branch_wallet_given_after = nil
        branch_wallet_consume_after = nil
        self.wallet_logs.create({
          :shop => self.shop,
          :wallet_log_type => WalletLog::WALLET_LOG_TYPE_RECHARGE,
          :money => recharge_amount,
          :account => account,
          :note => "管理员#{account.name}为该用户充值#{recharge_amount}元",
          :shop_wallet_given_after => shop_wallet_given_after,
          :shop_wallet_consume_after => shop_wallet_consume_after,
          :branch_wallet_given_after => branch_wallet_given_after,
          :branch_wallet_consume_after => branch_wallet_consume_after,
          :user_wallet_balance_after=> wallet
          })
    end
  end

  def recharge_amount
    @recharge_amount ||= 0.0;
  end

  def recharge_amount=(new_recharge_amount)
    @recharge_amount = new_recharge_amount
  end

  def self.user_info_from_wx(shop, fake_user_name)
    shop.system_configs.where(gonghao_type: false).each do |system_config|
      user_info = Message.user_info(fake_user_name, system_config)
      unless user_info["errcode"].present?
        return user_info
      end
    end
    return
  end

  # def pay_password
  #   @pay_password||= Password.new(pay_password_hash)
  # end

  # def pay_password=(new_password)
  #   @pay_password = Password.create(new_password)
  #   self.pay_password_hash = @pay_password
  # end

  def get_validation_code
    if self.validation_code.present?  and self.validation_code.is_activated?
      self.validation_code
    elsif validation_code.present?
      self.validation_code.destroy
      self.create_validation_code
    else
      self.create_validation_code
    end
  end

  private
  def after_update_total_amount_callback
      before = self.changes[:total_amount][0]
      after = self.changes[:total_amount][1]
      self.shop.vip_levels.auto_upgrade_levels.each do |vip_level|
        if vip_level.id == self.vip_level.id
          #级别已经达到无需升级
          return
        end
        if (self.vip_level.discount >= vip_level.discount) && (vip_level.min_total_amount <= after)  #and (vip_level.min_total_amount > before)
          self.vip_level = vip_level
          self.save
          return
        end
      end
  end
end
