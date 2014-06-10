#encoding: utf-8
class Mobile::OrdersController < MobileApplicationController
  before_action :set_order, only: [:detail]
  before_filter :set_cart_id, only: [:new, :create, :detail, :query, :cancel, :choose_order_type, :send_validation_code]
  include OrdersHelper
  include SmsMsgsHelper
  include MobileAlipayUtils
  #layout 'mobile_basic', only: [:show, :cancel]

  def choose_order_type
    supported_order_types = @current_branch.split_supported_order_types
    if supported_order_types.size == 1
      redirect_to new_mobile_shop_branch_order_path(@current_shop.slug, @current_branch, {:order_type=> supported_order_types[0]})
    end
  end

  def detail
  end

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

  # GET /orders/new
  def new
    @forms = @current_branch.form_elements.includes(:options)
    @user = current_user
    @cart = @current_branch.carts.find(current_cart.id)
    @cart.line_items.where(:quantity => 0).destroy_all
    if @cart.line_items.empty?
      flash[:error] = t('no product items in cart')
      redirect_to mobile_shop_branch_my_cart_path(@current_shop.slug, @current_branch)
      return
    end
    @order = @current_branch.orders.build
    @forms.each do |form|
      @order.form_contents.build form_element_id: form.id, label: form.statement
    end
    @order.delivery_time = Time.now+(@current_branch.min_order_time_gap + 10).minutes
    if @order.arrive_time.present?
      @order.arrive_time = Time.now+(@current_branch.min_order_time_gap + 10).minutes
    end
    @amount = get_amount(@cart)
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /orders
  # POST /orders.json
  def create
    if @current_user.is_blocked
      flash[:error] = "您已经被本公众账号列入黑名单，不允许再下单。如须申诉，请联系管理公众账号管理员或直接拨打#{@current_shop.telephone}"
      redirect_to list_mobile_shop_branch_products_path(@current_shop.slug, @current_branch)
      return
    end

    unless @current_branch.is_open
      flash[:error] = "该店已暂停营业"
      redirect_to list_mobile_shop_branch_products_path(@current_shop.slug, @current_branch)
      return
    end

    if @current_branch.enabled_verify_service_periods and not @current_branch.is_in_service_time?(Time.now)
      flash[:error] = "不在该店的服务时间内"
      redirect_to list_mobile_shop_branch_products_path(@current_shop.slug, @current_branch)
      return
    end

    if current_cart.line_items.empty?
      flash[:error] = t('no product items in cart')
      redirect_to mobile_shop_branch_my_cart_path(@current_shop.slug, @current_branch)
      return
    end

    @order = @current_branch.orders.build(order_params)
    @order[:delivery_time] = Time.parse order_params[:delivery_time] unless order_params[:delivery_time].nil?
=begin
    if not @order.deal_order_with_pay_type(current_cart)
      flash[:error] = "没有设置支付方式"
      redirect_to mobile_shop_branch_my_cart_path(@current_shop.slug, @current_branch)
      return
    end

    @user = User.find(@current_user.id)
    if @order.consume_wallet > 0
      if not @user.authenticate(params[:pay_password])
        flash[:error] = "支付密码不正确"
        redirect_to mobile_shop_branch_my_cart_path(@current_shop.slug, @current_branch)
        return
      end
    end
=end
    @order.deal_order_with_pay_type(current_cart)
    unless @current_branch.printers.get_feiyin_printers.empty?
      #只有飞印打印机才立即打印
      @order[:state] = Order::CONFIRMED
    else
      @order[:state] = Order::WAIT_CONFIRMED
    end

    respond_to do |format|
      if @order.save
        flash[:scrachpad_id] = @order.scrachpad.id if @order.scrachpad.present?
        OrderWorker.perform_in(1.second, @order.id, backend_shop_branch_order_url(@current_shop.slug, @current_branch, @order))
        user = current_cart.user
        @current_cart.destroy
        @current_cart = nil
        apply_new_cart(user, @current_branch)
        format.html {
          redirect_to detail_mobile_shop_branch_order_path(@current_shop.slug, @current_branch, @order), notice: "您的订单(编号：#{@order.id})已经成功提交！"
        }
        format.json { render action: 'show', status: :created, location: @order }
      else
        @user = current_user
        @cart = @current_branch.carts.find(current_cart.id)
        @amount = get_amount(@cart)
        format.html { render action: 'new' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def cancel
    @order = current_user.orders.find(params[:id])
    @order.errors.add(:base, '订单状态已改变，您无法取消订单')
    respond_to do |format|
      if @order.allow_change_state_for_user?.include?(Order::CANCELED)
        @order[:state] = Order::CANCELED
        if @order.save
          format.js{}
        else
          format.js{}
        end
      else
        @order.errors.add(:base, '订单状态已改变，您无法取消订单')
        format.js{}
      end
    end
  end

  def send_validation_code
    begin
      message_return = send_validation_msg(@current_branch, @current_user, params[:phone])
      @message = {message: message_return}
      respond_to do |format|
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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = @current_shop.orders.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
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
end