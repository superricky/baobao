#encoding: utf-8
require 'file_size_validator'
class BranchSlider < ActiveRecord::Base
  belongs_to :shop
  belongs_to :branch
  validates :branch, presence: true
  validates :desc, presence: true
  validate :max_branch_sliders_count, on: :create
  acts_as_list scope: :shop
  require 'carrierwave/orm/activerecord'
      mount_uploader :img, BranchSliderImageUploader
  validates :img, presence: true,
    :file_size => {
      :maximum => 0.5.megabytes.to_i
    }

  def total_branch_sliders
    BranchSlider.where(:shop_id => self.shop_id)
  end

  def max_branch_sliders_count
    if self.shop.is_multipe_base_version?
      self.errors.add(:base, "对不起，超过了推荐商户幻灯片最大数量(最大数量为#{shop.max_branch_sliders}张)") if shop.max_branch_sliders <= self.total_branch_sliders.count
    end
  end
end
