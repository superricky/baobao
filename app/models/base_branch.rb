class BaseBranch < ActiveRecord::Base

  acts_as_paranoid
  default_scope {order("position ASC")}
  self.table_name = "branches"
  belongs_to :shop
  after_create :set_position_attribute
  scope :root_base_branches, -> { where(:brand_chain_id => nil) }
  scope :active_branches, -> {where(:is_open=>true)}
  has_many :promotions, dependent: :destroy, foreign_key: "branch_id"
  #acts_as_list :scope => 'brand_chain_id is NULL and shop_id=#{shop_id}'
  require 'carrierwave/orm/activerecord'
  mount_uploader :image, BranchImageUploader
  mount_uploader :rect_image, BranchRectImageUploader
  validates :image,
    :file_size => {
      :maximum => 1.megabytes.to_i
    }
  validates :rect_image,
    :file_size => {
      :maximum => 0.5.megabytes.to_i
    }

  def is_branch?
    self.type == 'Branch'
  end

  def is_brand_chain?
    self.type == 'BrandChain'
  end

  private
  def set_position_attribute
    self.position = id
    self.save!
  end
end