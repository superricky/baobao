#encoding: utf-8
class DeliveryZone < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :branch
  validates :zone_name, presence: true, uniqueness: {message: "不能重复", scope: :branch_id}
  validates :charge, numericality: {greater_than_or_equal_to: 0}
end
