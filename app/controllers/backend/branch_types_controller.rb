#encoding: utf-8
class Backend::BranchTypesController < BackendApplicationController
  before_action :set_branch_type, only: [:show, :edit, :update, :destroy]

  # GET /branch_types
  # GET /branch_types.json
  def index
    @branch_types = @current_shop.branch_types
  end

  # GET /branch_types/1
  # GET /branch_types/1.json
  def show
    @branches = @branch_type.branches
  end

  # GET /branch_types/new
  def new
    @branch_type = @current_shop.branch_types.build
    respond_to do |format|
      format.js
      format.html
    end
  end

  # GET /branch_types/1/edit
  def edit
    respond_to do |format|
      format.js
      format.html
    end
  end

  # POST /branch_types
  # POST /branch_types.json
  def create
    @branch_type = @current_shop.branch_types.build(branch_type_params)

    respond_to do |format|
      if @branch_type.save
        format.html { redirect_to backend_shop_branch_type_path(@current_shop.slug, @branch_type), notice: '商户分类成功创建.' }
        format.js
        format.json { render action: 'show', status: :created, location: @branch_type }
      else
        format.html { render action: 'new' }
        format.js
        format.json { render json: @branch_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /branch_types/1
  # PATCH/PUT /branch_types/1.json
  def update
    respond_to do |format|
      if @branch_type.update(branch_type_params)
        format.html { redirect_to backend_shop_branch_type_path(@current_shop.slug, @branch_type), notice: '商户分类成功保存.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @branch_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /branch_types/1
  # DELETE /branch_types/1.json
  def destroy
    @branch_type.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_branch_types_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_branch_type
      @branch_type = @current_shop.branch_types.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def branch_type_params
      params.require(:branch_type).permit(:name)
    end
end
