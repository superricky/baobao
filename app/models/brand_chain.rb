#encoding: utf-8
class BrandChain < BaseBranch
  has_many :branches
  validate :valid_brand_chain, on: :create


  def valid_brand_chain
    self.errors.add(:base, "单店铺商户不允许创建连锁品牌类型") unless shop.max_branches_count > 1
  end

  def active_branches
    branches.where(:is_open=>true)
  end
end
