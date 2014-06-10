class Backend::ArticlesController < BackendApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  # POST /articles
  # POST /articles.json
  def create
    #logger.info params.to_json
    @material = @current_shop.materials.find(params[:material_id])
    @articles = @material.articles
    @article = @material.articles.build(article_params)
    respond_to do |format|
      if @article.save
        @article.set_position(params[:article][:position])
        format.js {}
      else
        logger.error "errors are #{@article.errors.to_json}"
        @errors = @article.errors
        format.js {}
      end
    end
  end

  def new
    @material = @current_shop.materials.find(params[:material_id])
    @article = @material.articles.new
  end


  def show
    respond_to do |format|
      format.js {}
    end
  end

  def edit
    @material = @current_shop.materials.find(params[:material_id])
    respond_to do |format|
      format.js {}
    end
  end

  def update
    @material = @current_shop.materials.find(params[:material_id])
    @article.set_position(params[:article][:position])
    @article.update_attributes(article_params.except(:position))
    respond_to do |format|
      format.js {}
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @material = @current_shop.materials.find(params[:material_id]) rescue nil
    @article.destroy
    respond_to do |format|
      format.js {}
    end
  end

  def preview
    @articles = @current_shop.materials.find(params[:material_id]).articles
  end

  private

  def authorize_parent
    authorize! :manage, (@material||@message)
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_article
    if params[:material_id]
      @article = @current_shop.materials.find(params[:material_id]).articles.find(params[:id])
    end
    if params[:message_id]
       @article = @current_shop.messages.find(params[:message_id]).articles.find(params[:id])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def article_params
    params.require(:article).permit(:title, :description, :image, :url, :material_id, :link_type, :position, :expiration_time, :support_promotion, :introduction)
  end
end