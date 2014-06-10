#encoding: utf-8
class Zone < ActiveRecord::Base
  belongs_to :shop
  has_many :sub_zones, class_name: "Zone", foreign_key: "parent_zone_id", dependent: :destroy
  has_and_belongs_to_many :branches
  belongs_to :parent_zone, class_name: "Zone"
  scope :root_zones, ->{ where(:parent_zone_id=>nil) }
  validates :name, presence: true, :uniqueness=>{:scope=>[:parent_zone_id, :shop_id]}
  validate :check_parent_zone_is_not_self
  validate :check_parent_zone_is_root
  attr_accessor :original_branches_count
  #skip_callback :save, :after, :store_avatar!, if: :pic_is_exist?
  def original_branches_count
    self.branches.count
  end

  def check_parent_zone_is_root
    if parent_zone.present?
      if parent_zone.parent_zone_id.present?
        self.errors.add(:parent_zone_id, "上级服务区域不能继续含有上级服务区域")
      end
      unless sub_zones.empty?
        sub_zones.each do |sub_zone|
          if sub_zone.sub_zone.present?
            self.errors.add(:base, "子服务区域不能再继续子下级服务区域")
          end
        end
      end
    end
  end

  def check_parent_zone_is_not_self
    self.errors.add(:parent_zone_id, "上级区域不能是本区域自身") if self.parent_zone_id.present? and self.parent_zone_id == self.id
  end

  def branches_count
    if self.parent_zone.present?
      original_branches_count
    else
      self.sub_zones.collect{|s| s.original_branches_count}.inject(:+)
    end
  end
end
