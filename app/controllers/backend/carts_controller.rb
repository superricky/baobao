class Backend::CartsController < BackendApplicationController
  before_action :set_cart, only: [:destroy, :show]


  # GET /carts
  # GET /carts.json
  def index
    @carts = @current_branch.carts.includes(:line_items).where('line_items.id IS NOT NULL').paginate(:page => params[:page], :per_page => 25)
  end

  def show
    @cart.line_items.where(:quantity => 0).destroy_all
    @line_items = @cart.line_items
    render 'backend/line_items/index'
  end

  # DELETE /carts/1
  # DELETE /carts/1.json
  def destroy
    @cart.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_branch_carts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart
      @cart = @current_branch.carts.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cart_params
      params[:cart]
    end
end
