#encoding: utf-8
class ProductSlider < ActiveRecord::Base
  belongs_to :branch
  has_one :shop, through: :branch
  belongs_to :product
  validates :product, presence: true
  validates :desc, presence: true
  validate :check_slider_count, on: :create
  acts_as_list scope: :branch
  require 'carrierwave/orm/activerecord'
      mount_uploader :img, ProductSliderImageUploader
  validates :img, presence: true,
    :file_size => {
      :maximum => 0.2.megabytes.to_i
    }


  def total_product_sliders
    ProductSlider.where(:branch_id => self.branch_id)
  end

  private
  def check_slider_count
    if self.shop.is_multipe_base_version?
      self.errors.add(:base, "对不起，超过了推荐产品幻灯片最大数量(最大数量为#{self.shop.product_slider_limit})") unless self.branch.product_sliders.count < self.shop.product_slider_limit
    end
  end
end
