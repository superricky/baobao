class WeixinpayFeedback < ActiveRecord::Base
  FEEDBACK_TYPE_REQUEST = 'request'
  FEEDBACK_TYPE_CONFIRM = 'confirm'
  FEEDBACK_TYPE_REJECT = 'reject'
  belongs_to :shop
  belongs_to :trade
  has_one :order, :through => :trade
  validates_presence_of :shop, :trade_id
  validates_uniqueness_of :feedback_id,  scope: :msg_type
  default_scope {order("created_at DESC")}

  scope :request_feedbacks, ->{where(:msg_type=>FEEDBACK_TYPE_REQUEST)}

  def system_config
    self.shop.system_configs.find_by_appId(self.appId)
  end

  def is_request?
    msg_type == FEEDBACK_TYPE_REQUEST
  end

  def is_confirm_result?
    msg_type == FEEDBACK_TYPE_CONFIRM
  end

  def is_reject_result?
    msg_type == FEEDBACK_TYPE_REJECT
  end
end
