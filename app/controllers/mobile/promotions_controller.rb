class Mobile::PromotionsController < MobileApplicationController
  before_filter :set_cart_id
  def detail_special_off
    @promotion = Promotion::get_current_promotion_for_branch(@current_branch)
  end

end
