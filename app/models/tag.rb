class Tag < ActiveRecord::Base
  has_many :products
  validates :name, presence: true, uniqueness:{scope: :branch_id}
  belongs_to :shop
  belongs_to :branch
end
