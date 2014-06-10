#encoding: utf-8
class WalletLog < ActiveRecord::Base
  WALLET_LOG_TYPE_RECHARGE = "recharge"
  WALLET_LOG_TYPE_RECHARGE_ROLLBACK = "recharge_rollback"
  WALLET_LOG_TYPE_PAY = "pay"
  WALLET_LOG_TYPE_ROLLBACK = "pay_rollback"
  WALLET_LOG_TYPE_SUCCESS = "pay_success"

  belongs_to :user, class_name: "BaseUser"
  belongs_to :shop
  belongs_to :order
  belongs_to :branch
  belongs_to :account
  belongs_to :recharge_log, class_name: "WalletLog"
  has_one :back_recharge_log, :class_name => 'WalletLog', :foreign_key => 'recharge_log_id'

  validates :user, :shop, presence: true
  validates :recharge_log, presence: true, if: "is_recharge_rollback_log?"
  before_save :before_save_recharge_rollback_money
  def is_recharge_log?
    self.wallet_log_type  == WALLET_LOG_TYPE_RECHARGE
  end

  def is_recharge_rollback_log?
    self.wallet_log_type  == WALLET_LOG_TYPE_RECHARGE_ROLLBACK
  end

  def recharge_can_rollback
    self.user.wallet >= self.money
  end

  private
  def before_save_recharge_rollback_money
    if self.wallet_log_type == WALLET_LOG_TYPE_RECHARGE_ROLLBACK
      self.user.decrement!(:wallet, self.money)
      self.shop.decrement!(:wallet_given, self.money)
      self.shop_wallet_given_after = self.shop.wallet_given
      self.shop_wallet_consume_after = self.shop.wallet_consume
      self.user_wallet_balance_after = self.user.wallet
    end
  end
end


