#encoding:utf-8
class Backend::CategoriesController < BackendApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy, :add_product, :change_position]
  include ProductsHelper
  before_action :current_special_off, only: [:show]

  # GET /categories
  # GET /categories.json
  def index
    @categories = @current_branch.categories.includes(:categories).
    where(category_id: 0).paginate(:page => params[:page], :per_page => 10)
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @products = @category.products.paginate(:page => params[:page], :per_page => 10)
    @branch_products = @current_branch.products
  end

  # GET /categories/new
  def new
    @category = @current_branch.categories.build
  end

  # GET /categories/1/edit
  def edit
  end

  def add_product
    unless params[:product_ids].present?
      notice = "请选择要添加的商品"
    else
      @category.products << Product.find(params[:product_ids])
      notice = "商品添加成功"
    end
    show
    redirect_to backend_shop_branch_category_path(@current_shop.slug, @current_branch, @category), notice: notice
  end

  def remove_product
    @category = @current_branch.categories.find(params[:category_id])
    @category.products.delete Product.find(params[:product_id])
    redirect_to backend_shop_branch_category_path(@current_shop.slug, @current_branch, @category)
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = @current_branch.categories.build(category_params)
    @category.shop = @current_shop
    respond_to do |format|
      if @category.save
        format.html { redirect_to backend_shop_branch_category_path(@current_shop.slug, @current_branch, @category), notice: t('Category was successfully created.') }
        format.json { render action: 'show', status: :created, location: @category }
      else
        format.html { render action: 'new' }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to backend_shop_branch_category_path(@current_shop.slug, @current_branch, @category), notice: t('Category was successfully updated.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_branch_categories_url }
      format.json { head :no_content }
    end
  end

  def change_position
    position = params[:position]
    position = Integer(position) rescue position
    if position.is_a? Fixnum
      @category.insert_at(position)
    else
      @category.send(position)
    end
    redirect_to backend_shop_branch_categories_path(@current_shop.slug, @current_branch)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = @current_branch.categories.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      if params[:category][:categories_attributes].present?
        params[:category][:categories_attributes].keys.each do |k|
          params[:category][:categories_attributes][k.to_s][:branch_id] = @current_branch.id
          params[:category][:categories_attributes][k.to_s][:shop_id] = @current_shop.id
        end
      end
      params.require(:category).permit(:name, categories_attributes: [:id, :name, :_destroy, :branch_id, :shop_id, :position])
    end
end
