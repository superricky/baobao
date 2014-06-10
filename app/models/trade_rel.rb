class TradeRel < ActiveRecord::Base
  belongs_to :user, class_name: "BaseUser"
  belongs_to :branch
end