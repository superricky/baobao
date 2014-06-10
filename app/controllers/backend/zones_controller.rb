#encoding: utf-8
class Backend::ZonesController < BackendApplicationController
  before_action :set_zone, only: [:show, :edit, :update, :destroy]

  # GET /zones
  # GET /zones.json
  def index
    @zones = @current_shop.zones.root_zones
  end

  # GET /zones/1
  # GET /zones/1.json
  def show
    @branches = @zone.branches
  end

  # GET /zones/new
  def new
    @zone = @current_shop.zones.build(:parent_zone_id=>params[:parent_zone_id])
  end

  # GET /zones/1/edit
  def edit
  end

  # POST /zones
  # POST /zones.json
  def create
    @zone = @current_shop.zones.build(zone_params)

    respond_to do |format|
      if @zone.save
        format.html { redirect_to backend_shop_zone_path(@current_shop.slug, @zone), notice: '服务区域成功创建.' }
        format.json { render action: 'show', status: :created, location: @zone }
      else
        format.html { render action: 'new' }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /zones/1
  # PATCH/PUT /zones/1.json
  def update
    respond_to do |format|
      if @zone.update(zone_params)
        format.html { redirect_to backend_shop_zone_path(@current_shop.slug, @zone), notice: '服务区域成功保存.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zones/1
  # DELETE /zones/1.json
  def destroy
    @zone.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_zones_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_zone
      @zone = @current_shop.zones.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def zone_params
      params.require(:zone).permit(:name, :parent_zone_id)
    end
end
