class MobileAlipay < ActiveRecord::Base
  belongs_to :shop
  validates_presence_of :pid, :pkey, :email, if: :use_mobile_alipay

  after_find do
    if self.shop.is_multipe_base_version? and self.use_mobile_alipay?
      self.update_attribute(:use_mobile_alipay, false)
    end
  end
end
