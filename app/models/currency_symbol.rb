class CurrencySymbol < ActiveRecord::Base
  validates :symbol, :decoration ,presence:true, uniqueness: {:scope => :shop_id}
  validates :shop, presence:true

  belongs_to :shop
end