#encoding: utf-8
class Backend::ServiceProductsController < BackendApplicationController
  before_action :set_service_product, only: [:show, :edit, :update, :destroy]

  # GET /service_products
  # GET /service_products.json
  def index
    @service_products = ServiceProduct.all
  end

  # GET /service_products/1
  # GET /service_products/1.json
  def show
  end

  # GET /service_products/new
  def new
    @service_product = ServiceProduct.new
  end

  # GET /service_products/1/edit
  def edit
  end

  # POST /service_products
  # POST /service_products.json
  def create
    @service_product = ServiceProduct.new(service_product_params)

    respond_to do |format|
      if @service_product.save
        format.html { redirect_to [:backend, @service_product], notice: 'Service product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @service_product }
      else
        format.html { render action: 'new' }
        format.json { render json: @service_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /service_products/1
  # PATCH/PUT /service_products/1.json
  def update
    respond_to do |format|
      if @service_product.update(service_product_params)
        format.html { redirect_to [:backend, @service_product], notice: 'Service product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @service_product.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_position
    @service_products = ServiceProduct.all
    if params[:service_product_ids].size != 2
      logger.error "The service product going to exchange are: #{params[:service_product_ids]}"
      @errors = "需要提供进行排序的服务套餐"
    else
      updated_service_products =  @service_products.find(params[:service_product_ids])
      @first_service_product = updated_service_products[0]
      @second_service_product = updated_service_products[1]
      position = @second_service_product.position
      @second_service_product.position = @first_service_product.position
      @first_service_product.position = position
      Branch.transaction do
          if not @first_service_product.save
            @errors = @first_service_product.errors.full_messages
            raise ActiveRecord::Rollback
          end
          if not @second_service_product.save
            @errors = @second_service_product.errors.full_messages
            raise ActiveRecord::Rollback
          end
      end
    end
    redirect_to backend_service_products_path
  end

  # DELETE /service_products/1
  # DELETE /service_products/1.json
  def destroy
    @service_product.destroy
    respond_to do |format|
      format.html { redirect_to backend_service_products_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_product
      @service_product = ServiceProduct.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_product_params
      params.require(:service_product).permit(:subject, :price, :description, :quantity, :product_type, :available_shop_versions=>[])
    end
end
