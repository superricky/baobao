#encoding: utf-8
class ProductUnit < ActiveRecord::Base
  belongs_to :shop
  belongs_to :branch

  validates :name, presence: true

  def is_system_unit?
    self.shop.nil?
  end

  def type_name
    if self.is_system_unit?
      "系统计量单位"
    elsif self.is_shop_unit?
      "点号计量单位"
    elsif self.is_branch_unit?
      "商户计量单位"
    else
      "未知计量单位"
    end
  end

  def is_shop_unit?
    self.shop.present? and self.branch.nil?
  end

  def is_branch_unit?
    self.shop.present? and self.branch.present?
  end

  def is_powered_by(account)
    if account.is_admin?
      true
    elsif account.is_boss? and self.shop.present? and self.shop == account.shop
      true
    elsif account.is_worker? and self.branch.present? and account.branch_ids.include?(self.branch_id)
      true
    else
      false
    end
  end
end
