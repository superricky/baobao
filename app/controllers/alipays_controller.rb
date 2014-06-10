class AlipaysController < ActionController::Base
  #protect_from_forgery :except => [:alipay_notify]
  #before_filter :set_my_fake_id, only: [:alipay_notify]
  #before_filter :validate_weixin, only: [:alipay_notify]

  def alipay_notify
    @service_sale_order = ServiceSaleOrder.find(params[:service_sale_order_id])
    logger.info params
    # except :controller_name, :action_name, :host, etc.
    notify_params = params.except(*request.path_parameters.keys)
    if Alipay::Notify.verify?(notify_params)
      # valid notify, code your business logic.
      if @service_sale_order.current_state == :new
        @service_sale_order.verify!(notify_params)
      end
      render :text => 'success'
    else
      render :text => 'error'
    end
  end

end