#encoding: utf-8
class Backend::ProductsController < BackendApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :change_position]
  before_action :current_special_off, only: [:index]

  include ProductsHelper
  # GET /products
  # GET /products.json
  def index
    @q= @current_branch.products.search(params[:q])
    @products = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 25)

    respond_to do |format|
      format.html {render :index}
      format.csv { send_data @current_branch.products.to_csv(col_sep: ",") }
    end
  end

  def search
    index
  end

  def change_position
    position = params[:position]
    position = Integer(position) rescue position
    if position.is_a? Fixnum
      @product.insert_at(position)
    else
      @product.send(position)
    end
    redirect_to backend_shop_branch_products_path(@current_shop.slug, @current_branch)
  end

  def batch_remove
    if product_params[:product_ids].nil? or product_params[:product_ids].empty?
      flash[:error] = "您必须选择要删除的产品!"
    else
      products = @current_branch.products.where(id:product_params[:product_ids])
      product_names = products.map(&:name).join(',')
      products.destroy_all
      flash[:success] = "恭喜您，成功删除如下产品:#{product_names}."
    end
    redirect_to backend_shop_branch_products_path(@current_shop.slug, @current_branch)
  end

  def batch_added
    if product_params[:product_ids].present?
      @current_branch.products.set_addeds product_params[:product_ids]
      product_names = @current_branch.products.where(id: product_params[:product_ids]).map(&:name).join ","
      flash[:success] = "恭喜您，成功上架如下产品:#{product_names}"
    else
      flash[:error] = "您必须选择要上架的产品!"
    end
    redirect_to backend_shop_branch_products_path(@current_shop.slug, @current_branch)
  end

  def batch_shelve
    if product_params[:product_ids].present?
      @current_branch.products.set_shelves product_params[:product_ids]
      product_names = @current_branch.products.where(id: product_params[:product_ids]).map(&:name).join ","
      flash[:success] = "恭喜您，成功下架如下产品:#{product_names}"
    else
      flash[:error] = "您必须选择要下架的产品!"
    end
    redirect_to backend_shop_branch_products_path(@current_shop.slug, @current_branch)
  end


  def copy_to_branch

    if batch_params[:branches].nil? or
      batch_params[:branches].empty? or
      batch_params[:product_ids].nil? or
      batch_params[:product_ids].empty?
      flash[:error] = "您必须选择要拷贝的目标商户"
      redirect_to backend_shop_branch_products_path(@current_shop.slug, @current_branch)
    else
      products = @current_branch.products.find(batch_params[:product_ids])
      branches = @current_shop.branches.find(batch_params[:branches])
      begin
        skiped_product_msgs = Branch.copy_products_to_branch(branches, products)
      rescue Exception => e
        flash[:error] = e.message
        redirect_to backend_shop_branch_products_path(@current_shop.slug, @current_branch)
        return
      end

      flash[:success] = skiped_product_msgs.empty? ? "恭喜您，所有产品已成功拷贝至目标商户，请进入相应商户进行浏览" : skiped_product_msgs.join('<br/>')
      redirect_to backend_shop_branch_products_path(@current_shop.slug, @current_branch)
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = @current_branch.products.build
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = @current_branch.products.build(product_params)
    @product.shop = @current_shop
    @product.category_ids = params[:product][:category_ids][1..-1]
    respond_to do |format|
      if @product.save
        format.html { redirect_to backend_shop_branch_product_path(@current_shop.slug, @current_branch, @product), notice: t('Product was successfully created.') }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      @product.category_ids = params[:product][:category_ids][1..-1]
      if @product.update_attributes(product_params.except("category_ids"))
        format.html { redirect_to backend_shop_branch_product_path(@current_shop.slug, @current_branch, @product), notice: t('Product was successfully updated.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_branch_products_url(@current_shop.slug, @current_branch) }
      format.json { head :no_content }
    end
  end

  def import_product
    begin
      Product.update_and_create_from_file(params[:file], @current_branch)
    rescue => e
      logger.error e.message
      flash[:error] = e.message
    end
    redirect_to backend_shop_branch_products_path(@current_shop.slug, @current_branch)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = @current_branch.products.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      if action_name == 'copy_to_branch' and (@current_account.is_admin? or @current_account.is_boss?)
        params.require(:product).permit(:branches=>[], :product_ids=>[])
      elsif ['batch_remove', 'batch_added', 'batch_shelve'].index action_name
        params.require(:product).permit(:product_ids=>[])
      else
        params.require(:product).permit(:name, :description, :image, :price, :stock, :tag_id, :product_unit, :category_ids=>[])
      end
    end

    def batch_params
      if @current_account.is_admin? or @current_account.is_boss?
        params.require(:product).permit(:branches=>[], :product_ids=>[])
      end
    end
end
