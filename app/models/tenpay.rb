class Tenpay < ActiveRecord::Base
  belongs_to :shop
  validates_presence_of :shop
  validates_presence_of :pid, :pkey, if: :use_tenpay
  after_find do
    if self.shop.is_multipe_base_version? and self.use_tenpay?
      self.update_attribute(:use_tenpay, false)
    end
  end
end
