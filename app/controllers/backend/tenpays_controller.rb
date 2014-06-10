class Backend::TenpaysController < BackendApplicationController
  before_action :set_tenpay, only: [:show, :edit, :update, :destroy]


  # GET /tenpays/1
  # GET /tenpays/1.json
  def show
  end

  # GET /tenpays/new
  def new
    @tenpay = @current_shop.build_tenpay
  end

  # GET /tenpays/1/edit
  def edit
  end

  # POST /tenpays
  # POST /tenpays.json
  def create
    @tenpay = @current_shop.build_tenpay(tenpay_params)

    respond_to do |format|
      if @tenpay.save
        format.html { redirect_to backend_shop_tenpay_path(@current_shop), notice: 'Tenpay was successfully created.' }
        format.json { render action: 'show', status: :created, location: @tenpay }
      else
        format.html { render action: 'new' }
        format.json { render json: @tenpay.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tenpays/1
  # PATCH/PUT /tenpays/1.json
  def update
    respond_to do |format|
      if @tenpay.update(tenpay_params)
        format.html { redirect_to backend_shop_tenpay_path(@current_shop), notice: 'Tenpay was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @tenpay.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tenpays/1
  # DELETE /tenpays/1.json
  def destroy
    @tenpay.destroy
    respond_to do |format|
      format.html { redirect_to tenpays_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tenpay
      @tenpay = @current_shop.tenpay||@current_shop.create_tenpay
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tenpay_params
      params.require(:tenpay).permit(:shop_id, :pid, :pkey, :use_tenpay)
    end
end
