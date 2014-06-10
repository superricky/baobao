class Backend::WeixinpayFeedbacksController < BackendApplicationController
  def index
    @weixinpay_feedbacks = @current_shop.weixinpay_feedbacks.request_feedbacks
  end
end
