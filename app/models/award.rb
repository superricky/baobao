class Award < ActiveRecord::Base
  belongs_to :branch
  validates :name, presence: true, uniqueness: {:scope=>:branch_id}
end
