class Webstore::BranchesController < WebstoreApplicationController

  def show
    @categories = []
    @current_branch = @current_shop.online_branches.find params[:id]
    impressionist(@current_branch, '',  unique: [:controller_name, :action_name, :session_hash, :user_id])
    @current_branch.categories.includes(:products).except(:order).where(products: {down: false, deleted_at: nil}).each do |category|
      next if category.products.size == 0
      @categories << category
    end
    @hot_products_of_week = Product.populars_of_week_by_branch(@current_branch).limit 5
    if current_member
      @order = OrderWebstore.new name: current_member.name, phone: current_member.phone, address: current_member.default_address
    else
      @order = OrderWebstore.new
    end

    session[:branch] ||= @current_branch.id
    if @current_branch.id != session[:branch]
      cookies[:cart] = ""
      session[:branch] = @current_branch.id
    end
  end
end
