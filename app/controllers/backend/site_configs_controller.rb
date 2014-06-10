class Backend::SiteConfigsController < BackendApplicationController
  before_action :set_site_config, only: [:show, :edit, :update, :destroy]

  # GET /site_configs
  # GET /site_configs.json
  def index
    @site_configs = SiteConfig.all
  end

  # GET /site_configs/1/edit
  def edit
  end

  # PATCH/PUT /site_configs/1
  # PATCH/PUT /site_configs/1.json
  def update
    respond_to do |format|
      if @site_config.update(site_config_params)
        format.html { redirect_to action: :index, notice: t('Site config was successfully updated.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @site_config.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site_config
      @site_config = SiteConfig.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_config_params
      params.require(:site_config).permit(:key, :display_name, :value_type, :value_s, :value_b)
    end
end
