class Backend::PromotionsController < BackendApplicationController

  before_action :set_promotion, only: [:show_special_off,:edit_special_off, :update_special_off, :destroy_special_off]


  def index_special_off
    @promotions = @current_branch.promotions.where(:key => Promotion::PROMOTION_SPECIAL_OFF)
  end

  def new_special_off
    @promotion = @current_branch.promotions.build(:key => Promotion::PROMOTION_SPECIAL_OFF)
    @promotion.end_time = Time.now + 1.month
    3.times do|i|
      @promotion.promotion_details.build(:product=> @current_branch.products[i])
    end
  end


  def show_special_off

  end

  # GET /promotions/1/edit
  def edit_special_off

  end

  def create_special_off
    @promotion = @current_branch.promotions.build(promotion_params)
    @promotion.key = Promotion::PROMOTION_SPECIAL_OFF
    logger.info @promotion.to_json
    if @promotion.save
      redirect_to show_special_off_backend_shop_branch_promotion_path(@current_shop.slug, @current_branch, @promotion), notice: t('special off was succesfully created!')
    else
      render action: 'new_special_off'
    end
  end

  def destroy_special_off
    @promotion.destroy
    redirect_to index_special_off_backend_shop_branch_promotions_path(@current_shop.slug, @current_branch)
  end

  # PATCH/PUT /promotions/1
  # PATCH/PUT /promotions/1.json
  def update_special_off

    respond_to do |format|
      if @promotion.update(promotion_params)
        format.html { redirect_to show_special_off_backend_shop_branch_promotion_path(@current_shop.slug, @current_branch, @promotion), notice: t('special off was successfully updated.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit_special_off' }
        format.json { render json: @promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  private


    def set_promotion
        @promotion = @current_branch.promotions.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def promotion_params
      params.require(:promotion).permit(:name, :description, :image, :start_time, :end_time, promotion_details_attributes:  [:id, :price, :product_id, :_destroy ])
    end
end
