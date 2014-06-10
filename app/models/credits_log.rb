#encoding: utf-8
class CreditsLog < ActiveRecord::Base
  before_save :before_save_consume_credits
  before_save :before_save_consume_rollback_credits
  CREDITS_LOG_TYPE_RECHARGE = "recharge"
  CREDITS_LOG_TYPE_CONSUME_ROLLBACK = "consume_rollback"
  CREDITS_LOG_TYPE_CONSUME = "consume"
  CREDITS_LOG_TYPE_PAY = "pay"
  CREDITS_LOG_TYPE_FOLLOW = "follow"
  CREDITS_LOG_TYPE_PAY_ROLLBACK = "pay_rollback"
  CREDITS_LOG_TYPE_PAY_SUCCESS = "pay_success"

  CREDITS_LOG_TYPE_RECHARGE_NAME = "用户获得积分"
  CREDITS_LOG_TYPE_CONSUME_ROLLBACK_NAME = "积分换购回退"
  CREDITS_LOG_TYPE_CONSUME_NAME = "积分换购"
  CREDITS_LOG_TYPE_PAY_NAME = "积分支付"
  CREDITS_LOG_TYPE_FOLLOW_NAME = "关注获得积分"
  CREDITS_LOG_TYPE_PAY_ROLLBACK_NAME = "积分支付回退"
  CREDITS_LOG_TYPE_PAY_SUCCESS_NAME = "积分支付到帐"

  #CREDITSLOG_TYPE_CHARGE = true#积分充值
  #CREDITSLOG_TYPE_CONSUME = false#积分消费
  belongs_to :shop
  belongs_to :branch
  belongs_to :user, class_name: "BaseUser"
  belongs_to :order
  belongs_to :account
  belongs_to :consume_log, class_name: "CreditsLog"
  has_one :back_consume_log, :class_name => 'CreditsLog', :foreign_key => 'consume_log_id'
  validates_numericality_of :credits, :greater_than => 0

  validates :credit_log_type, :inclusion => { :in => [
      CREDITS_LOG_TYPE_RECHARGE,
      CREDITS_LOG_TYPE_CONSUME,
      CREDITS_LOG_TYPE_CONSUME_ROLLBACK,
      CREDITS_LOG_TYPE_PAY,
      CREDITS_LOG_TYPE_PAY_ROLLBACK,
      CREDITS_LOG_TYPE_PAY_SUCCESS,
      CREDITS_LOG_TYPE_FOLLOW] }
  validates :user, :shop, :credits, :note, presence: true
  validates :account, presence: true, if: :is_human_operate?
  validates :order, :branch, presence: true, unless: :is_other_way_get_credits?
  validates :consume_log_id, presence: true, if: :is_consume_rollback_type?
  #validates :shop_credits_given_after, :shop_credits_consume_after, :branch_credits_given_after, :branch_credits_consume_after, :user_credits_balance_after, presence: true
  validates_length_of :note, maximum:255
  default_scope  { order("created_at DESC") }

  def credit_log_type_name
    if is_recharge?
      CREDITS_LOG_TYPE_RECHARGE_NAME
    elsif is_pay?
      CREDITS_LOG_TYPE_PAY_NAME
    elsif is_pay_rollback?
      CREDITS_LOG_TYPE_PAY_ROLLBACK_NAME
    elsif is_consume_rollback_type?
      CREDITS_LOG_TYPE_CONSUME_ROLLBACK_NAME
    elsif is_pay_success?
      CREDITS_LOG_TYPE_PAY_SUCCESS_NAME
    elsif is_consume_type?
      CREDITS_LOG_TYPE_CONSUME_NAME
    elsif is_follow_type?
      CREDITS_LOG_TYPE_FOLLOW_NAME
    end
  end

  def is_consume_rollback?
    credit_log_type == CREDITS_LOG_TYPE_CONSUME_ROLLBACK
  end

  def is_recharge?
    credit_log_type == CREDITS_LOG_TYPE_RECHARGE
  end

  def is_pay?
    credit_log_type == CREDITS_LOG_TYPE_PAY
  end

  def is_pay_rollback?
    credit_log_type == CREDITS_LOG_TYPE_PAY_ROLLBACK
  end

  def is_pay_success?
    credit_log_type == CREDITS_LOG_TYPE_PAY_SUCCESS
  end

  def is_human_operate?
    is_consume_type?
  end

  def is_other_way_get_credits?
    is_follow_type? or is_consume_type? or is_consume_rollback?
  end

  def is_consume_type?
    credit_log_type == CREDITS_LOG_TYPE_CONSUME
  end

  def is_consume_rollback_type?
    credit_log_type == CREDITS_LOG_TYPE_CONSUME_ROLLBACK
  end

  def is_follow_type?
    credit_log_type == CREDITS_LOG_TYPE_FOLLOW
  end

  def before_save_consume_credits
    if is_consume_type?
      if not self.shop.use_credits
        self.errors[:base] = "该点账号未启用积分功能"
        return false
      end

      if self.credits.nil?
        self.errors[:credits] = "积分数量不能为空"
        return false
      end

      if self.user.credits < self.credits
        self.errors[:credits] = "用户剩余积分不足"
        return false
      end
      self.user.decrement!(:credits, self.credits)
      self.branch.increment!(:credits_consume, self.credits)
      self.shop.increment!(:credits_consume, self.credits)
      self.shop_credits_given_after = self.shop.credits_given
      self.shop_credits_consume_after = self.shop.credits_consume
      self.branch_credits_given_after = self.branch.credits_given
      self.branch_credits_consume_after = self.branch.credits_consume
      self.user_credits_balance_after = self.user.credits
      return true
    end
  end

  def before_save_consume_rollback_credits
    if is_consume_rollback_type?
      if not self.shop.use_credits
        self.errors[:base] = "该点账号未启用积分功能"
        return false
      end
      self.user.increment!(:credits, self.credits)
      self.branch.decrement!(:credits_consume, self.credits)
      self.shop.decrement!(:credits_consume, self.credits)
      self.shop_credits_given_after = self.shop.credits_given
      self.shop_credits_consume_after = self.shop.credits_consume
      self.branch_credits_given_after = self.branch.credits_given
      self.branch_credits_consume_after = self.branch.credits_consume
      self.user_credits_balance_after = self.user.credits
      return true
    end
  end
end