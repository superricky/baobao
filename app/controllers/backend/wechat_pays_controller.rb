#encoding: utf-8
class Backend::WechatPaysController < BackendApplicationController

  skip_load_and_authorize_resource
  authorize_resource :class => false

  before_filter :set_wechat_pay, only: [:show, :edit, :update]

  def show
  end

  def edit
  end

  def update
    if @wechat_pay.update(wechat_pay_params)
      redirect_to backend_shop_wechat_pay_path(@current_shop, @wechat_pay), notice: '微信支付设置成功'
    else
      render action: 'edit'
    end
  end

  def index
    @system_configs = @current_shop.system_configs.varified_service_account
  end

  private
  def set_wechat_pay
    @wechat_pay = @current_shop.system_configs.varified_service_account.find(params[:id])
  end

  def wechat_pay_params
    params.require(:system_config).permit(:support_weixin_pay, :paySignKey, :partnerId, :partnerKey)
  end
end
