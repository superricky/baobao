#encoding:utf-8
require 'file_size_validator'
class Promotion < ActiveRecord::Base
  PROMOTION_SPECIAL_OFF = 'special_off'
  validates :key, :name, :start_time, :end_time, presence: true
  validates_inclusion_of :key, :in => [PROMOTION_SPECIAL_OFF]
  has_many :promotion_configs
  belongs_to :branch
  has_one :shop, through: :branch
  has_many :promotion_details, inverse_of: :promotion, dependent: :destroy
  validate :validate_unique_promotion_details
  validate :validate_promotion_schedule
  accepts_nested_attributes_for :promotion_details, allow_destroy: true

  has_many :products, through: :promotion_details
  validates :promotion_details, presence: true
  default_scope {order("start_time DESC")}
  require 'carrierwave/orm/activerecord'
    mount_uploader :image, PromotionImageUploader
  validates :image,
    :file_size => {
      :maximum => 0.5.megabytes.to_i
    }

  def validate_promotion_schedule
    #if start_time < Time.now
    #  self.errors[:start_time] = "活动开始时间不能晚于当前时间"
    #end
    if start_time >= end_time
      self.errors[:start_time] = "活动开始时间不能等于或者晚于结束时间"
    end

    other_promotions = Promotion.where(:branch=>branch)
    other_promotions.each do|promotion|
      next if promotion.id == id
      if (promotion.start_time..promotion.end_time).cover? start_time
        self.errors[:start_time] = "活动开始时间与另一个活动\"#{promotion.name}\"重叠"
        return
      end

      if (promotion.start_time..promotion.end_time).cover? end_time
        self.errors[:end_time] = "活动结束时间与另一个活动\"#{promotion.name}\"重叠"
        return
      end

      if (start_time..end_time).cover? promotion.start_time
        self.errors[:start_time] = "活动结束时间与另一个活动\"#{promotion.name}\"重叠"
        return
      end
    end
  end

  def validate_unique_promotion_details
    if promotion_details.empty?
      self.errors[:base] = "促销产品不能为空"
      return
    end
    validate_uniqueness_of_in_memory(
      promotion_details , [:product_id], '同一个促销活动下面不允许重复的促销产品')
  end


  def self.get_current_promotion_for_branch(branch)
    promotions = branch.promotions.where("start_time <= ? and end_time > ?", Time.now, Time.now)
    if promotions.empty?
      return nil
    else
      promotions.first
    end
  end

end

module ActiveRecord
  class Base
    # Validate that the the objects in +collection+ are unique
    # when compared against all their non-blank +attrs+. If not
    # add +message+ to the base errors.
    def validate_uniqueness_of_in_memory(collection, attrs, message)
      hashes = collection.inject({}) do |hash, record|
        key = attrs.map {|a| record.send(a).to_s }.join
        if key.blank? || record.marked_for_destruction?
        key = record.object_id
        end
        hash[key] = record unless hash[key]
        hash
      end
      if collection.length > hashes.length
        self.errors[:base] = message
      end
    end
  end
end