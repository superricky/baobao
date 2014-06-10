class VipLevel < ActiveRecord::Base
  belongs_to :shop
  has_many :users
  validates :discount, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1.0}
  validates :name, presence: true, uniqueness:{:scope=>:shop_id}
  validates :min_total_amount, :numericality => { :greater_than_or_equal_to => 0}, if: :auto_upgrade
  default_scope  {order("discount ASC").order("min_total_amount DESC")}
  scope :auto_upgrade_levels, ->{ where(:auto_upgrade=>true).order("min_total_amount DESC")}

end
