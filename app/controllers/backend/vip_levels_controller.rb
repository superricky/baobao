#encoding: utf-8
class Backend::VipLevelsController < BackendApplicationController
  before_action :set_vip_level, only: [:show, :edit, :update, :destroy]

  # GET /vip_levels
  # GET /vip_levels.json
  def index
    @vip_levels = @current_shop.vip_levels
  end

  # GET /vip_levels/1
  # GET /vip_levels/1.json
  def show
  end

  # GET /vip_levels/new
  def new
    @vip_level = @current_shop.vip_levels.build
  end

  # GET /vip_levels/1/edit
  def edit
  end

  # POST /vip_levels
  # POST /vip_levels.json
  def create
    @vip_level = @current_shop.vip_levels.build(vip_level_params)

    respond_to do |format|
      if @vip_level.save
        format.html { redirect_to backend_shop_vip_level_path(@current_shop.slug, @vip_level), notice: '会员级别成功保存.' }
        format.json { render action: 'show', status: :created, location: @vip_level }
      else
        format.html { render action: 'new' }
        format.json { render json: @vip_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vip_levels/1
  # PATCH/PUT /vip_levels/1.json
  def update
    respond_to do |format|
      if @vip_level.update(vip_level_params)
        format.html { redirect_to backend_shop_vip_level_path(@current_shop.slug, @vip_level), notice: '会员级别成功保存' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @vip_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vip_levels/1
  # DELETE /vip_levels/1.json
  def destroy
    @vip_level.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_vip_levels_url(@current_shop.slug) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vip_level
      @vip_level = @current_shop.vip_levels.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vip_level_params
      params.require(:vip_level).permit(:shop_id, :name, :discount, :min_total_amount, :auto_upgrade)
    end
end
