#encoding: utf-8
class PromotionDetail < ActiveRecord::Base
  belongs_to :product
  validates :product, presence: true
  belongs_to :promotion
  validates :promotion, presence: true
  validates :price, presence: true
  
  #validates :product_id, :uniqueness => {:scope=>:promotion_id}
  #validates_uniqueness_of :product_id, :scope => :promotion_id
end