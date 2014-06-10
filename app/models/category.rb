class Category < ActiveRecord::Base
  validates :name, presence:true, uniqueness: {:scope => :branch_id}
  has_and_belongs_to_many :products,  :uniq => true
  belongs_to :shop
  belongs_to :branch
  acts_as_list scope: :branch
  belongs_to :category
  has_many :categories, class_name: "Category", foreign_key: :category_id, dependent: :destroy
  accepts_nested_attributes_for :categories, allow_destroy: true
end
