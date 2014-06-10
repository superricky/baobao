class Mobile::LineItemsController < MobileApplicationController
  before_action :set_line_item, only: [:destroy]
  before_filter :set_cart_id, except: :destroy

  def create
    @cart = current_cart
    @product = @current_branch.products.find(params[:line_items][:product_id])
    if @product.nil?
      @line_items.errors[:product_id] = t('product is not exist')
      render action: 'new'
      return
    end

    @line_item = @cart.line_items.find_by_product_id(@product.id)
    if @line_item.nil?
      @line_item = @cart.line_items.build(:product => @product, :quantity => params[:line_items][:quantity])
      @line_item.quantity ||= 1
    else
      if params[:line_items][:quantity]
        @line_item.quantity = params[:line_items][:quantity]
      else
        @line_item.quantity += 1
      end
    end

    respond_to do |format|
      if @line_item.save
        format.json { render action: 'show', status: :created }
      else
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line_item
      @line_item = LineItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def line_item_params
      params.require(:line_item).permit(:product_id, :cart_id, :quantity)
    end
end
