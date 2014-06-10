#encoding: utf-8
class Backend::MaterialsController < BackendApplicationController
  before_action :set_material, only: [:show, :edit, :update, :destroy]

  # GET /materials
  # GET /materials.json
  def index
    @materials = Material.valid_materials @current_shop.materials
  end

  # GET /materials/1
  # GET /materials/1.json
  def show
    @material.msg_type = params[:msg_type] if params[:msg_type]
    @articles = @material.articles
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end

  # GET /materials/new
  def new
    @material = @current_shop.materials.new
    respond_to do |format|
      format.html { redirect_to edit_backend_shop_material_path(@current_shop.slug, @material) }
      format.js
    end
  end

  # GET /materials/1/edit
  def edit
    @articles = @material.articles
    @article = Article.new
    respond_to do |format|
      format.js
      format.html
    end
  end

  # POST /materials
  # POST /materials.json
  def create
    @material = @current_shop.materials.build(material_params)
    respond_to do |format|
      if @material.save
        format.html { redirect_to backend_shop_material_path(@current_shop.slug, @material), notice: t('Material was successfully created.') }
        format.json { render action: 'show', status: :created, location: @material }
        format.js
      else
        format.html { render action: 'new' }
        format.js {}
        format.json { render json: @material.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /materials/1
  # PATCH/PUT /materials/1.json
  def update
    respond_to do |format|
      if @material.update(material_params)
        format.js {}
        format.html { redirect_to backend_shop_material_path(@current_shop.slug, @material), notice: t('Material was successfully updated.') }
        format.json { head :no_content }
      else
        @articles = @material.articles
        @article = Article.new
        format.html { render action: 'edit' }
        format.js {}
        format.json { render json: @material.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /materials/1
  # DELETE /materials/1.json
  def destroy
    @material.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to backend_shop_materials_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_material
      @material = @current_shop.materials.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def material_params
      params.require(:material).permit(:msg_type, :material_name, :content, :title, :description, :music_url, :hq_music_url)
    end
end
