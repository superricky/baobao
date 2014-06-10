class PromotionLog < ActiveRecord::Base
  belongs_to :article
  belongs_to :shop
end
