#encoding: utf-8
class Backend::ProductUnitsController < BackendApplicationController
  before_action :set_product_unit, only: [:show, :edit, :update, :destroy]

  include ProductUnitsHelper
  # GET /product_units
  # GET /product_units.json
  def index
    if @current_shop.nil?
      @product_units = ProductUnit.where(:shop_id=>nil)
    elsif @current_branch.nil? and not @current_account.is_worker?
      #@product_units = ProductUnit.where("shop_id in [NULL, #{@current_shop.id}] and branch_id is NULL")
      @product_units = ProductUnit.where(:shop_id => [nil, @current_shop.id], :branch_id=>nil)
    else
      @product_units = ProductUnit.where(:shop_id => [nil, @current_shop.id], :branch_id=>[nil, @current_branch.id])
    end
  end

  # GET /product_units/1
  # GET /product_units/1.json
  def show
  end

  # GET /product_units/new
  def new
    if @current_shop.nil?
      @product_unit = ProductUnit.new
    elsif @current_branch.nil? and not @current_account.is_worker?
      @product_unit = @current_shop.product_units.build
    else
      @product_unit = @current_branch.product_units.build
    end
  end

  # GET /product_units/1/edit
  def edit
  end

  # POST /product_units
  # POST /product_units.json
  def create
    @product_unit = ProductUnit.new(product_unit_params)
    @product_unit.shop = @current_shop unless @current_shop.nil?
    @product_unit.branch = @current_branch unless @current_branch.nil?

    respond_to do |format|
      if @product_unit.save
        format.html { redirect_to get_product_unit_path(@product_unit), notice: t('Product unit was successfully created.') }
        format.json { render action: 'show', status: :created, location: @product_unit }
      else
        format.html { render action: 'new' }
        format.json { render json: @product_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @product_unit.is_powered_by(@current_account) and @product_unit.update(product_unit_params)
        format.html { redirect_to get_product_unit_path(@product_unit), notice: t('Product unit was successfully updated.') }
        format.json { head :no_content }
      elsif not @product_unit.is_powered_by(@current_account)
        @product_unit.errors[:base] = "您无权对该计量单位进行操作管理"
        format.html { render action: 'edit' }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_units/1
  # DELETE /product_units/1.json
  def destroy
    if @product_unit.is_powered_by(@current_account)
      @product_unit.destroy
      respond_to do |format|
        format.html { redirect_to get_product_units_path }
        format.json { head :no_content }
      end
    else
      @product_unit.errors[:base] = "您无权对该计量单位进行操作管理"
      respond_to do |format|
        format.html { redirect_to get_product_units_path }
        format.json { head :no_content }
      end
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_unit
      @product_unit = ProductUnit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_unit_params
      params.require(:product_unit).permit(:name)
    end
end
