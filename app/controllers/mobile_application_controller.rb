class MobileApplicationController < ApplicationController
  layout "mobile/application"
  before_action :check_current_branch
  before_action :check_branch_expired
  before_action :redirect_if_not_mobile
  before_action :set_pay
  private
    def set_pay
      @tenpay = @current_shop.get_tenpay
      @mobile_alipay = @current_shop.get_mobile_alipay
    end
end
