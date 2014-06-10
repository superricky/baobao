class Backend::MobileAlipaysController < BackendApplicationController
  before_action :set_mobile_alipay, only: [:show, :edit, :update, :destroy]


  # GET /mobile_alipays/1
  # GET /mobile_alipays/1.json
  def show
  end

  # GET /mobile_alipays/new
  def new
    @mobile_alipay = @current_shop.build_mobile_alipay
  end

  # GET /mobile_alipays/1/edit
  def edit
  end

  # POST /mobile_alipays
  # POST /mobile_alipays.json
  def create
    @mobile_alipay = @current_shop.build_mobile_alipay(mobile_alipay_params)

    respond_to do |format|
      if @mobile_alipay.save
        format.html { redirect_to backend_shop_mobile_alipay_path(@current_shop), notice: 'Mobile alipay was successfully created.' }
        format.json { render action: 'show', status: :created, location: @mobile_alipay }
      else
        format.html { render action: 'new' }
        format.json { render json: @mobile_alipay.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mobile_alipays/1
  # PATCH/PUT /mobile_alipays/1.json
  def update
    respond_to do |format|
      if @mobile_alipay.update(mobile_alipay_params)
        format.html { redirect_to backend_shop_mobile_alipay_path(@current_shop), notice: 'Mobile alipay was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @mobile_alipay.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mobile_alipays/1
  # DELETE /mobile_alipays/1.json
  def destroy
    @mobile_alipay.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_mobile_alipays_url(@current_shop) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mobile_alipay
      @mobile_alipay = @current_shop.mobile_alipay||@current_shop.create_mobile_alipay
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mobile_alipay_params
      params.require(:mobile_alipay).permit(:pid, :pkey, :email, :use_mobile_alipay, :shop_id)
    end
end
