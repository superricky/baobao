class Mobile::CartsController < MobileApplicationController
  before_filter :set_cart_id, only: [:my_cart, :clear_my_cart]

  # GET /carts/1
  # GET /carts/1.json
  def my_cart
    @cart = @current_branch.carts.find(current_cart.id)
    @cart.line_items.where(:quantity => 0).destroy_all
    render layout: 'mobile/application'
  end

  def clear_my_cart
    if current_cart
      current_cart.line_items.delete_all
    end
    redirect_to mobile_shop_branch_my_cart_path(@current_shop.slug, @current_branch)
  end
end
