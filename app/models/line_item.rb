class LineItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :cart, counter_cache: true
  validates :quantity, presence: true
  validates :product, presence: true
  
end
