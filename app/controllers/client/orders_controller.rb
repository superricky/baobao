#encoding: utf-8
class Client::OrdersController < ClientApplicationController

  include SmsMsgsHelper
  include MobileAlipayUtils
  layout 'mobile_basic', only: [:show, :cancel]

  def query
    states = params[:states].map{|state| state.to_i}
    @orders = current_user.orders.where("state IN (?)", states)
  end

  def show
    @order = @current_shop.orders.find(params[:id])
  end

  def mobile_alipay
    @order = @current_shop.orders.find(params[:id])
    mobile_alipay = @current_shop.mobile_alipay
    notify_url = notify_mobile_alipay_url(@current_shop)
    call_back_url = client_order_url(@current_shop, @order)
    url = mobile_alipay_execute_url(mobile_alipay, @order, call_back_url, notify_url)
    redirect_to url
  end

  def cancel
    @order = @current_user.orders.find(params[:id])
    respond_to do |format|
      if @order.allow_change_state_for_user?.include?(Order::CANCELED)
        @order[:state] = Order::CANCELED
        if @order.save
          flash[:success] = "订单已成功取消"
          format.json { render :json => flash[:success] }
          format.html { redirect_to client_order_path(@current_shop, @order)}
        end
      else
        @order.errors.add(:base, '订单状态已改变，您无法取消订单')
      end
      format.json { render :json => @order.errors.full_messages.first }
      format.html { render 'show' }
    end
  end

  def reminder
    @order = @current_user.orders.find(params[:id])
    respond_to do |format|
      if @order.is_remind_order? && @order.update_attributes(last_remind_date: DateTime.now)
        RemindOrderWorker.perform_in(1.second, @order.id)
        format.json {render json: "催单成功，店家会尽快处理您的订单！"}
      else
        format.json {render json: "您已催过单，请给店家一点时间来处理您的订单！"}
      end
    end
  end


  def create
    @current_branch = @current_shop.branches.find(order_params[:branch_id])
    @order = @current_branch.orders.build(order_params)
    @order.user=@current_user

     if @current_user.is_blocked
      @order.errors[:base] = "您已经被本公众账号列入黑名单，不允许再下单。如须申诉，请联系管理公众账号管理员或直接拨打#{@current_shop.telephone}"
      render status: :bad_request
      return
    end

    unless @current_branch.is_open
      @order.errors[:base] = "该店已暂停营业"
      render status: :bad_request
      return
    end

    if @current_branch.enabled_verify_service_periods and not @current_branch.is_in_service_time?(Time.now)
      @order.errors[:base] = "不在该店的服务时间内"
      render status: :bad_request
      return
    end

    if current_cart.line_items.empty?
      @order.errors[:base]  = t('no product items in cart')
      render status: :bad_request
      return
    end

    if not @order.deal_order_with_pay_type(current_cart)
      render status: :bad_request
      return
    end
    @user = User.find(@current_user.id)
    if @order.consume_wallet > 0
      if not @user.authenticate(params[:pay_password])
        @order.errors[:base]  = "支付密码不正确"
        render status: :bad_request
        return
      end
    end


    unless @current_branch.printers.get_feiyin_printers.empty?
      #只有飞印打印机才立即打印
      @order[:state] = Order::CONFIRMED
    else
      @order[:state] = Order::WAIT_CONFIRMED
    end

    if @order.save
      OrderWorker.perform_in(1.second, @order.id, backend_shop_branch_order_url(@current_shop.slug, @current_branch, @order))
      user = current_cart.user
      @current_cart.destroy
      @current_cart = nil
      apply_new_cart(user, @current_branch)
    else
      render status: :bad_request
      return
    end

  end

  def send_validation_code

    begin
      message_return = send_validation_msg(@current_branch, @current_user, params[:phone])
      respond_to do |format|
        @message = {message: message_return}
        format.json { render :json => @message.to_json, :status => 200}
        return
      end
    rescue SmsMsgNoFeeException, BranchOrShopNotUseSmsValidation => e
      @message = {message: "#{e.message},您可以尝试直接提交订单"}
    rescue SmsMsgTooFrequently=> e
      @message = {message: "#{e.message}, 短信发送可能有延迟哦"}
    rescue ValidationSmsMsgOverLimit=> e
      @message = {message: "#{e.message},您可以使用曾经使用过的电话号码进行下单"}
    rescue SmsMsgSendErrorException => e
      @message = {message: "#{e.message}, 点击重新发送"}
    end
    respond_to do |format|
      format.json { render :json => @message, :status => 400}
    end
  end

  def validation_code
    respond_to do |format|
      if @current_user.get_validation_code.code == params[:code]
        @current_user.validated_phones.create(:phone => params[:phone])
        @message = {message: "验证成功!"}
        format.json { render :status => 200}
      else
        @message = {message: "验证码错误!"}
        format.json { render :status => 400}
      end
    end

  end

  private

  def order_params
    params = form_contents_record
    params.require(:order).permit(:name,
      :phone,
      :address,
      :note,
      :delivery_time,
      :state,
      :order_type,
      :desk_no,
      :guest_num,
      :arrive_time,
      :validation_code,
      :branch_id,
      :pay_type,
      :consume_credit,
      :consume_wallet,
      :delivery_zone_id,
      :delivery_period,
      form_contents_attributes: [:id, :form_element_id, :label, :content, :order_id]
      )
  end


  def form_contents_record
    if params[:form_contents].present?
      form_contents_attributes = {}
      params[:form_contents].each_with_index do |f, i|
        form_element = FormElement.find f[:form_element_id]
        if f[:type].to_sym == :quote
          form_option = FormElementOption.find f[:content]
          form_contents_attributes.merge!({i.to_s=>package_form_content(f, form_element, form_option)})
        else
          form_contents_attributes.merge!({i.to_s=>package_form_content(f, form_element)})
        end
      end
      params[:order][:form_contents_attributes] = form_contents_attributes
      params.delete :form_contents
    end
    params
  end

  def package_form_content(data, form_element, form_option = nil)
    {form_element_id: form_element.id, label: form_element.statement, content: (form_option ? form_option.statement : data[:content])}
  end
end
