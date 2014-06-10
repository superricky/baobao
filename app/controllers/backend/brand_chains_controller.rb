#encoding: utf-8
class Backend::BrandChainsController < BackendApplicationController
  before_action :set_brand_chain, only: [:show, :edit, :update, :destroy, :change_position]

  # GET /brand_chains
  # GET /brand_chains.json
  def index
    @brand_chains = @current_shop.brand_chains
  end

  # GET /brand_chains/1
  # GET /brand_chains/1.json
  def show
  end

  # GET /brand_chains/new
  def new
    @brand_chain = @current_shop.brand_chains.build
    respond_to do |format|
      format.js
      format.html
    end
  end

  # GET /brand_chains/1/edit
  def edit
  end

  # POST /brand_chains
  # POST /brand_chains.json
  def create
    @brand_chain = @current_shop.brand_chains.build(brand_chain_params)

    respond_to do |format|
      if @brand_chain.save
        format.html { redirect_to backend_shop_brand_chain_path(@current_shop, @brand_chain), notice: '成功创建连锁品牌!' }
        format.js
        format.json { render action: 'show', status: :created, location: @brand_chain }
      else
        format.html { render action: 'new' }
        format.js
        format.json { render json: @brand_chain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /brand_chains/1
  # PATCH/PUT /brand_chains/1.json
  def update
    respond_to do |format|
      if @brand_chain.update(brand_chain_params)
        format.html { redirect_to backend_shop_brand_chain_path(@current_shop, @brand_chain), notice: '成功更新连锁品牌!' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @brand_chain.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /brand_chains/1
  # DELETE /brand_chains/1.json
  def destroy
    @brand_chain.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_brand_chains_url(@current_shop) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_brand_chain
      @brand_chain = @current_shop.brand_chains.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def brand_chain_params
      params.require(:brand_chain).permit(:name, :branches_count, :image, :introduction, :is_open, :position, :branch_ids=>[])
    end
end
