#encoding: utf-8
require "setting"
class SystemConfig < ActiveRecord::Base
  GONGHAOTYPES =  [[I18n.t('subscribe_account'), true], [I18n.t('service_account'), false]]
  FAKEID_REGEX = /\Agh_[a-zA-Z0-9]{12}\Z/i
  validates :token, presence: true
  validates :my_fake_id, presence: true, length:{is:15}, format: {with: FAKEID_REGEX}
  validates :my_fake_id, :uniqueness=>{:scope=>:shop_id}

  belongs_to :shop
  has_and_belongs_to_many :menus, :uniq => true
  validate :check_max_system_configs, on: :create

  validates_presence_of :appId, :appSecret, if: :be_verified?
  validates_presence_of :paySignKey, :partnerId, :partnerKey, :appId, :appSecret, if: :support_weixin_pay?
  validates :appId,  :partnerId, uniqueness: { :scope => :shop_id }, :allow_blank=>true, :allow_nil=>true

  scope :service_account, -> {where(gonghao_type: false)}
  scope :subscribe_account, -> {where(gonghao_type: true)}
  scope :varified_service_account, -> {where(:gonghao_type=>false, :be_verified=>true)}

  def users
    shop.users.find_by_my_fake_id(self.my_fake_id) rescue []
  end

  def self.get_send_order_system_config
    Shop.find(Settings.public_account.shop_slug).system_configs.find_by(my_fake_id: Settings.public_account.my_fake_id) rescue nil
  end

  def is_subscribe_account?
    gonghao_type
  end

  def subscribe_account_str
    if gonghao_type == true
      I18n.t('subscribe_account')
    else
      I18n.t('service_account')
    end
  end

  def check_max_system_configs
    self.errors.add(:base, "多商户基本版最多绑定一个公众帐号") if shop.is_multipe_base_version? and self.shop.system_configs.count >= 1
  end

  def can_define_menu?
    appId.present? and appSecret.present?
  end


end
