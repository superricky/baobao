class BranchType < ActiveRecord::Base
  belongs_to :shop
  has_many :branches
  validates :name, presence: true
end
