class Report < ActiveRecord::Base
  belongs_to :shop
  validates :title, :content, presence: true
end
