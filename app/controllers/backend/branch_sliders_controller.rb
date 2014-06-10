class Backend::BranchSlidersController < BackendApplicationController
  before_action :set_branch_slider, only: [:show, :edit, :update, :destroy, :change_position]

  # GET /branch_sliders
  # GET /branch_sliders.json
  def index
    @branch_sliders = @current_shop.branch_sliders
  end

  def change_position
    position = params[:position]
    position = Integer(position) rescue position
    if position.is_a? Fixnum
      @branch_slider.insert_at(position)
    else
      @branch_slider.send(position)
    end
    redirect_to backend_shop_branch_sliders_path(@current_shop.slug)
  end

  # GET /branch_sliders/1
  # GET /branch_sliders/1.json
  def show
  end

  # GET /branch_sliders/new
  def new
    @branch_slider = @current_shop.branch_sliders.build
  end

  # GET /branch_sliders/1/edit
  def edit
  end

  # POST /branch_sliders
  # POST /branch_sliders.json
  def create
    @branch_slider = @current_shop.branch_sliders.build(branch_slider_params)

    respond_to do |format|
      if @branch_slider.save
        format.html { redirect_to backend_shop_branch_slider_path(@current_shop.slug, @branch_slider), notice: 'Branch slider was successfully created.' }
        format.json { render action: 'show', status: :created, location: @branch_slider }
      else
        format.html { render action: 'new' }
        format.json { render json: @branch_slider.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /branch_sliders/1
  # PATCH/PUT /branch_sliders/1.json
  def update
    respond_to do |format|
      if @branch_slider.update(branch_slider_params)
        format.html { redirect_to backend_shop_branch_slider_path(@current_shop.slug, @branch_slider), notice: 'Branch slider was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @branch_slider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /branch_sliders/1
  # DELETE /branch_sliders/1.json
  def destroy
    @branch_slider.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_branch_sliders_url(@current_shop.slug) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_branch_slider
      @branch_slider = @current_shop.branch_sliders.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def branch_slider_params
      params.require(:branch_slider).permit(:img, :desc, :branch_id, :position)
    end
end
