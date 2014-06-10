class Backend::TagsController < BackendApplicationController
  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  # GET /tags
  # GET /tags.json
  def index
    @tags = @current_branch.tags
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
  end

  # GET /tags/new
  def new
    @tag = @current_branch.tags.build
  end

  # GET /tags/1/edit
  def edit
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = @current_branch.tags.build(tag_params)
    @tag.shop = @current_shop
    respond_to do |format|
      if @tag.save
        format.html { redirect_to backend_shop_branch_tag_path(@current_shop.slug, @current_branch, @tag), notice: t('Tag was successfully created.') }
        format.json { render action: 'show', status: :created, location: @tag }
      else
        format.html { render action: 'new' }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to backend_shop_branch_tag_path(@current_shop.slug, @current_branch, @tag), notice: t('Tag was successfully updated.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_branch_tags_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = @current_branch.tags.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(:name)
    end
end
