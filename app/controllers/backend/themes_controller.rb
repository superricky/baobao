#encoding:utf-8
class Backend::ThemesController < BackendApplicationController
  before_action :set_theme, only: [:show, :edit, :update, :destroy]

  # GET /themes/1
  # GET /themes/1.json
  def show
  end

  # GET /themes/1/edit
  def edit
  end

  # PATCH/PUT /themes/1
  # PATCH/PUT /themes/1.json
  def update
    respond_to do |format|
      if @theme.update(theme_params)
        format.html { redirect_to backend_shop_theme_path(@current_shop.slug), notice: '成功保存新主题' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_theme
      @theme = @current_shop.theme||@current_shop.create_theme
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def theme_params
      params.require(:theme).permit(:background_color, :text_color, :header_bg_color, :header_text_color, :navbar_bg_color, :navbar_text_color, :menu_bg_color, :menu_text_color, :theme_type)
    end
end
