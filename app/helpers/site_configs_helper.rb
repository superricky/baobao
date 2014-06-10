#encoding: utf-8
module SiteConfigsHelper
  def find_or_set_title
    title = SiteConfig.find_by_key('title')
    if title.nil?
      title = SiteConfig.create!(
        :key => 'title',
        :display_name => '站点名称',
        :value_type => 'string',
        :value_s => '融商'
      )
    end
    title.value_s
  end

  def find_shop_or_branch_title
    if not @current_branch.nil?
      @current_branch.name
    elsif not @current_shop.nil?
      @current_shop.name
    else
      find_or_set_title
    end
  end

  def find_shop_or_branch_or_product_title
    if @product.present?
      @product.name
    else
      find_shop_or_branch_title
    end
  end
end
