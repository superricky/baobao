module ProductsHelper

  def current_special_off
      current_time = Time.now
      special_offs = @current_branch.promotions.where("promotions.key = ? and promotions.start_time <= ? and promotions.end_time > ?",
         Promotion::PROMOTION_SPECIAL_OFF, current_time, current_time)
      if not special_offs.empty?
        @current_special_off = special_offs.first
      else
        @current_special_off = nil
      end

  end

  def get_product_units_list
    ProductUnit.where(:shop_id=>[nil, @current_shop.id], :branch_id=>[nil, @current_branch.id])
  end

  def get_current_product_promotion
    Promotion.get_current_promotion_for_branch(@product.branch).promotion_details.find_by_product_id(@product.id) rescue nil
  end
end
