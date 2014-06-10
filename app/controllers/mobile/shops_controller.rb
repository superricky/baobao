class Mobile::ShopsController < MobileApplicationController
  before_action :set_shop, only: [:about_my_shop]

  def about_my_shop
  end

  private

  def set_shop
    @shop = Shop.find(params[:id])
  end
end
