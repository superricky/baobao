#encoding: utf-8
class Backend::ProductSlidersController < BackendApplicationController
  before_action :set_product_slider, only: [:show, :edit, :update, :destroy, :change_position]

  # GET /product_sliders
  # GET /product_sliders.json
  def index
    @product_sliders = @current_branch.product_sliders
  end

  # GET /product_sliders/1
  # GET /product_sliders/1.json
  def show
  end

  # GET /product_sliders/new
  def new
    @product_slider = @current_branch.product_sliders.build
  end

  def change_position
    position = params[:position]
    position = Integer(position) rescue position
    if position.is_a? Fixnum
      @product_slider.insert_at(position)
    else
      @product_slider.send(position)
    end
    redirect_to backend_shop_branch_product_sliders_path(@current_shop.slug, @current_branch)
  end

  # GET /product_sliders/1/edit
  def edit
  end

  # POST /product_sliders
  # POST /product_sliders.json
  def create
    @product_slider = @current_branch.product_sliders.build(product_slider_params)

    respond_to do |format|
      if @product_slider.save
        format.html { redirect_to backend_shop_branch_product_slider_path(@current_shop.slug, @current_branch, @product_slider), notice: '产品幻灯片成功创建.' }
        format.json { render action: 'show', status: :created, location: @product_slider }
      else
        format.html { render action: 'new' }
        format.json { render json: @product_slider.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_sliders/1
  # PATCH/PUT /product_sliders/1.json
  def update
    respond_to do |format|
      if @product_slider.update(product_slider_params)
        format.html { redirect_to backend_shop_branch_product_slider_path(@current_shop.slug, @current_branch, @product_slider), notice: '产品幻灯片成功更新.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product_slider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_sliders/1
  # DELETE /product_sliders/1.json
  def destroy
    @product_slider.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_branch_product_sliders_url(@current_shop.slug, @current_branch) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_slider
      @product_slider = @current_branch.product_sliders.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_slider_params
      params.require(:product_slider).permit(:img, :desc, :position, :product_id)
    end
end
