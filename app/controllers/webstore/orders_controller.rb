#encoding:utf-8;
class Webstore::OrdersController < WebstoreApplicationController
  include SmsMsgsHelper

  def index
    @orders = current_member.orders.includes(:shop).includes(:form_contents).where("").order("id desc").limit 90
  end

  def send_phone_validation_code
    begin
      message_return = send_validation_msg(@current_branch, current_member, params[:phone])
      respond_to do |format|
        @message = {message: message_return}
        format.json { render :json => @message.to_json, :status => 200}
        return
      end
    rescue SmsMsgNoFeeException, BranchOrShopNotUseSmsValidation => e
      @message = {message: "#{e.message}, 您可以尝试直接提交订单"}
    rescue SmsMsgTooFrequently=> e
      @message = {message: "#{e.message}, 短信发送可能有延迟哦"}
    rescue ValidationSmsMsgOverLimit=> e
      @message = {message: "#{e.message}, 您可以使用曾经使用过的电话号码进行下单"}
    rescue SmsMsgSendErrorException => e
      @message = {message: "#{e.message}, 点击重新发送"}
    end
    respond_to do |format|
      format.json { render :json => @message, :status => 400}
    end
  end

  def validation_code
    respond_to do |format|
      if current_member.get_validation_code.code == params[:code]
        current_member.validated_phones.create(:phone => params[:phone])
        @message = {message: "验证成功!"}
        format.json { render :status => 200}
      else
        @message = {message: "验证码错误!"}
        format.json { render :status => 400}
      end
    end
  end

  def create
    @order = OrderWebstore.new order_params
    @cart = CartMember.new line_items_count: @order.order_items.count, shop_id: @current_shop.id, branch_id: @current_branch.id
    @cart.user = current_member
    @order.order_items.each do |item|
      @cart.line_items.build product_id: item.product_id, quantity: item.quantity
    end
    @order.user = current_member

    #if @current_user.is_blocked
    #  @order.errors[:base] = "您已经被本公众账号列入黑名单，不允许再下单。如须申诉，请联系管理公众账号管理员或直接拨打#{@current_shop.telephone}"
    #  render status: :bad_request
    #  return
    #end

    unless @current_branch.is_open
      @order.errors[:base] = "该店已暂停营业"
      render status: :bad_request
      return
    end

    if @current_branch.enabled_verify_service_periods and not @current_branch.is_on_service?
      @order.errors[:base] = "不在该店的服务时间内"
      render status: :bad_request
      return
    end

    #if current_cart.line_items.empty?
    #  @order.errors[:base]  = t('no product items in cart')
    #  render status: :bad_request
    #  return
    #end

    #current_cart = CartMember.new shop_id: @current_shop.id, branch_id: @current_branch.id, user_id: current_member.id
    #carts = []
    #cookies[:cart].split(",").each do |id|
    #end

    @order[:pay_type] = Order::PAY_ON_RECEIVE_PAYMENT_TYPE
    if not @order.deal_order_with_pay_type(@cart)
      render status: :bad_request
      return
    end

    #@user = User.find(@current_user.id)
    #if (@order.consume_wallet > 0) && !@user.authenticate(params[:pay_password])
    #  @order.errors[:base]  = "支付密码不正确"
    #  render status: :bad_request
    #  return
    #end

    unless @current_branch.printers.get_feiyin_printers.empty?
      #只有飞印打印机才立即打印
      @order[:state] = Order::CONFIRMED
    else
      @order[:state] = Order::WAIT_CONFIRMED
    end

    respond_to do |f|
      if @order.save
        form_contents_record
        OrderWorker.perform_in(1.second, @order.id, backend_shop_branch_order_url(@current_shop.slug, @current_branch, @order))
        #user = current_cart.user
        #@current_cart.destroys
        #@current_cart = nil
        #apply_new_cart(user, @current_branch)
        f.json {render :json => "", status: 200}
      else
        f.json {render :json => @order.errors.full_messages.to_json, status: 403}
      end
    end
  end

  private

  def order_params
    params[:order_webstore].merge!({branch_id: @current_branch.id})
    params.require(:order_webstore).permit(
      :name,
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
      :consume_credit,
      :consume_wallet,
      :delivery_zone_id,
      :delivery_period,
      form_contents_attributes: [:id, :content, :label, :form_element_id],
      order_items_attributes: [:id, :name, :price, :quantity, :product_unit, :product_id]
      )
  end

  def order_params_without_items
    params[:order_webstore].merge!({branch_id: @current_branch.id})
    params.require(:order_webstore).permit(
      :name,
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
      :consume_credit,
      :consume_wallet,
      form_contents_attributes: [:id, :content, :label, :form_element_id]
      )
  end

  def form_contents_record
    if params[:form_contents].present? && @order
      params[:form_contents].each do |table|
        form_element = FormElement.find table[:form_element_id]
        if table[:type].to_sym == :quote
          form_option = FormElementOption.find table[:content]
          @order.form_contents.create form_element_id: table[:form_element_id], content: form_option.statement, label: form_element.statement
        else
          @order.form_contents.create form_element_id: table[:form_element_id], content: table[:content], label: form_element.statement
        end
      end
    end
  end
end