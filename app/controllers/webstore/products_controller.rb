class Webstore::ProductsController < WebstoreApplicationController
  #before_action :set_objects
  def show
    @product = @current_branch.products.find params[:id]
  end
end
