class WeixinpayWarning < ActiveRecord::Base
  belongs_to :shop
  validates_presence_of :appId, :shop
  default_scope {order("created_at DESC")}

  def system_config
    self.shop.system_configs.find_by_appId(self.appId)
  end
end
