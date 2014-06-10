#encoding: utf-8
class SmsMsg < ActiveRecord::Base
  ORDERMSG_TYPE_VALIDATE_CODE = 'validation_code'
  ORDERMSG_TYPE_ORDER = 'order'
  ORDERMSG_TYPE_CUSTOME = 'custom'
  belongs_to :branch, counter_cache: true
  belongs_to :sms_msg_owner, :class_name => "BaseUser"
  validates :sms_msg_owner, presence: true, if: :is_validation_msg?
  validates :branch, presence: true
  validates :to, presence: true, :format=> {:with => VALID_PHONE_REGEX}
  validates :body, presence: true
  default_scope { order('created_at DESC') }
  after_create :update_count
  after_create :after_create_callback

  ransacker :time, :formatter => proc {|v| Date.today - 1.send(v) } do |parent|
    parent.table[:date_created]
  end

  def is_order_msg?
    order_msg_type == ORDERMSG_TYPE_ORDER
  end

  def is_validation_msg?
    order_msg_type == ORDERMSG_TYPE_VALIDATE_CODE
  end

  def is_custom_msg?
    order_msg_type == ORDERMSG_TYPE_CUSTOME
  end

  def order_msg_name
    if is_order_msg?
      "订单短信"
    elsif is_validation_msg?
      "验证码短信"
    elsif is_custom_msg?
      "自定义短信"
    end
  end

  def shop
    self.branch.shop rescue nil
  end

  def size
    #由于每条短信都会加上”【拓单宝】“的后缀，导致实际发送的内容只能是65个字,原本一条短信是70个字
    (body.size  +  65  - 1) / 65
  end

  private

  def after_create_callback
    begin
      if is_validation_msg?
        if self.sms_msg_owner.last_sent_validation_code_time.present? and
            self.sms_msg_owner.last_sent_validation_code_time.strftime("%Y-%m-%d") == Time.now.strftime("%Y-%m-%d")
          self.sms_msg_owner.increment(:sent_validation_code_times_in_today)
        else
          self.sms_msg_owner.sent_validation_code_times_in_today = 1
        end
        self.sms_msg_owner.last_sent_validation_code_time = Time.now
        self.sms_msg_owner.save!
      end
    rescue => e
      logger.error e.message
      raise ActiveRecord::Rollback
    end
  end

  def update_count
    shop = self.branch.shop.increment(:sms_msgs_count, self.size)
    shop.save!
  end
end
