class Backend::CustomUiSettingsController < BackendApplicationController
  before_action :set_custom_ui_setting, only: [:edit, :update]

  # GET /custom_ui_settings
  # GET /custom_ui_settings.json
  def show
    @custom_ui_setting = @current_branch.get_custom_ui_setting
  end

  # GET /custom_ui_settings/1/edit
  def edit
  end

  # PATCH/PUT /custom_ui_settings/1
  # PATCH/PUT /custom_ui_settings/1.json
  def update
    respond_to do |format|
      if @custom_ui_setting.update(custom_ui_setting_params)
        format.html { redirect_to  backend_shop_branch_custom_ui_setting_path(@current_shop.slug, @current_branch), notice: t('Custom ui setting was successfully updated.') }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_custom_ui_setting
      @custom_ui_setting = @current_branch.get_custom_ui_setting
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def custom_ui_setting_params
      params.require(:custom_ui_setting).permit(:order_delivery_btn, :order_eat_in_hall_btn, :order_order_seat, :pay_on_receive, :pay_by_wallet, :pay_by_credits, :note_place_holder)
    end
end
