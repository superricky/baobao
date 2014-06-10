require 'file_size_validator'
class Article < ActiveRecord::Base
  validates :title, presence: true

  ARTICLE_SHOW_LINK = "article"
  SHOP_OR_BRANCH_LINK = "shop_or_branch"
  OUTSIDE_THE_WEB_LINK = "other_web_link"
  ARTICLE_TYPE_PROMOTION = "promotion"

  belongs_to :owner, polymorphic: true
  has_many :promotion_logs

  validates :expiration_time, presence: true, if: :support_promotion

  belongs_to :material, -> { joins(:articles).where("articles.owner_type = 'Material'")}, foreign_key: 'owner_id', class_name: "Material"
  acts_as_list scope: [:owner_id, :owner_type]
  belongs_to :material, -> { where("articles.owner_type = 'Material'")}, foreign_key: 'owner_id', class_name: "Material"
  require 'carrierwave/orm/activerecord'
      mount_uploader :image, ArticleImageUploader
  validates :image, :file_size => { :maximum => 0.5.megabytes.to_i }

  scope :promotion_articles, -> {
    where(support_promotion: true)
  }

  def shop
    self.material.shop
  end

  def article_sharer_count
    self.promotion_logs.select("sharer").uniq.count
  end

  def article_browser_count
    self.promotion_logs.select("browser").uniq.count
  end

  def article_browser_follow_count
    self.promotion_logs.where.not(browser_nickname: nil).uniq.count
  end

  def article_promotion_ranking
    self.promotion_logs.all.group_by{|p| p.sharer}.sort_by{|k, v| v.length}.reverse
  end

  def get_user_promotion_count(user)
    Hash[self.promotion_logs.load.group_by{|p| p.sharer}.sort_by{|k, v| v.length}.map{|a| [a[0], a[1].size]}][user.fake_user_name].to_i
  end
  def set_position(str)
    str = Integer(str) rescue str
    if str.is_a? Fixnum
      self.insert_at(str)
    else
      self.send(str)
    end
  end

end