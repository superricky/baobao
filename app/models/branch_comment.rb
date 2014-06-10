#encoding: utf-8
class BranchComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :shop, counter_cache: true
  belongs_to :branch, counter_cache: true
  validates :name, :content, :branch, :shop, :user, presence: true
  validate :user_has_order_of_branch, on: :create
  after_save :evaluate_average_level
  validates_numericality_of :level, :greater_or_equal_than => 0, :less_or_equal_than => 5
  scope :published_comments, -> { where(:can_pub => true) }
  scope :published_or_my_comments,  ->(user) { where('can_pub = true or user_id= ?', user.id) }
  default_scope -> {order("created_at DESC")}

  private
  def user_has_order_of_branch
    if user.orders.where(:branch=>self.branch, :state =>[Order::DELIVERED, Order::COMPLETED]).empty?
      self.errors.add(:base, "您需要在该商户拥有已完成的订单，才能发表评论")
    end
  end

  def evaluate_average_level
    sum = branch.branch_comments.published_comments.map(&:level).inject{|sum, n| sum+n}||0.0
    count = branch.branch_comments.published_comments.count
    if count == 0
      self.branch.average_level = 5.0
    else
      self.branch.average_level = sum/count.to_f
    end
    self.branch.save!
  end
end
