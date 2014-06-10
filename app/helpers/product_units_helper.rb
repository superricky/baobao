module ProductUnitsHelper

  def get_product_unit_path(product)
    if @current_shop.nil?
      backend_product_unit_path(product)
    elsif @current_shop.present? and @current_branch.nil?
      backend_shop_product_unit_path(@current_shop.slug, product)
    elsif @current_shop.present? and @current_branch.present?
      backend_shop_branch_product_unit_path(@current_shop.slug, @current_branch, product)
    end
  end

  def get_product_units_path
    if @current_shop.nil?
      backend_product_units_path
    elsif @current_shop.present? and @current_branch.nil?
      backend_shop_product_units_path(@current_shop.slug)
    elsif @current_shop.present? and @current_branch.present?
      backend_shop_branch_product_units_path(@current_shop.slug, @current_branch)
    end
  end

  def get_new_product_unit_path
    "#{get_product_units_path}/new"
  end

  def get_edit_product_unit_path(product)
    "#{get_product_unit_path(product)}/edit"
  end

  def get_create_product_unit_path
    "#{get_product_units_path}/new"
  end
end
