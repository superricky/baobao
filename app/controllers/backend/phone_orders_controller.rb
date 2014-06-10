#encoding: utf-8
class Backend::PhoneOrdersController < BackendApplicationController

  before_action :set_branch, except: [:branch_list]

  skip_load_and_authorize_resource
  authorize_resource :class => false

  respond_to :js, :json

  def branch_list
    if @current_account.is_boss? or @current_account.is_admin?
      @branch_list = @current_shop.branches.active_branches
    else
      @branch_list = @current_account.branches.active_branches
    end

  end

  def phone_user_info
    @phone_users = @current_shop.phone_users.where(phone: params[:phone]).where.not(name: nil)
    respond_to do |format|
      if @phone_users.present?
        format.json
      else
        format.json {render status: :bad_request}
      end
    end
  end

  def category_list
    @category_list=@current_branch.categories.where(category_id: 0).includes(:products).includes(categories:[:products])
    @order =  PhoneOrder.new
    @order.form_contents.build
  end

  def order_create
    @order = PhoneOrder.new phone_order_params

    @order.branch = @current_branch
    unless @current_branch.is_open
      @order.errors[:base] = "该店已暂停营业"
      respond_to do |format|
        @order.form_contents.clear
        @order.form_contents.build
        format.json {render "order_form", status: :bad_request}
      end
      return
    end
    if @current_branch.enabled_verify_service_periods and not @current_branch.is_on_service?
      @order.errors[:base] = "不在该店的服务时间内"
      respond_to do |format|
        @order.form_contents.clear
        @order.form_contents.build
        format.json {render "order_form", status: :bad_request}
      end
      return
    end
    if !params[:line_items] or params[:line_items].size <= 0
      @order.errors[:base] = t('no product items in cart')
      respond_to do |format|
        @order.form_contents.clear
        @order.form_contents.build
        format.json {render "order_form", status: :bad_request}
      end
      return
    end
    @cart = CartPhoneUser.new line_items_count: params[:line_items].size, shop_id: @current_shop.id, branch_id: @current_branch.id
    if phone_order_params[:order_type] != Order::ORDERTYPE_EAT_IN_HALL && phone_order_params[:user_id].present?
      phone_user = @current_shop.phone_users.find(phone_order_params[:user_id]) rescue nil
      @order.name = phone_user.name
    elsif phone_order_params[:phone].present?
      phone_user = @current_shop.phone_users.where(phone: phone_order_params[:phone], name: phone_order_params[:name]).first_or_create
    else
      phone_user = PhoneUser.new
    end
    @cart.user = phone_user
    params[:line_items].each do |key, line_item|
      @cart.line_items.build product_id: line_item[:product_id], quantity: line_item[:quantity]
    end
    @order.user = phone_user

    @order[:pay_type] = Order::PAY_ON_RECEIVE_PAYMENT_TYPE
    @order[:delivery_time] = Time.parse phone_order_params[:delivery_time] unless phone_order_params[:delivery_time].nil?
    @order.deal_order_with_pay_type(@cart)
    unless @current_branch.printers.get_feiyin_printers.empty?
      @order[:state] = Order::CONFIRMED
    else
      @order[:state] = Order::WAIT_CONFIRMED
    end

    respond_to do |format|
      if @order.save
        OrderWorker.perform_in(1.second, @order.id, backend_shop_branch_order_url(@current_shop.slug, @current_branch, @order))
        format.json {render "show_order"}
      else
        @order.form_contents.clear
        @order.form_contents.build
        format.json {render "order_form", status: :bad_request}
      end
    end
  end

  private
    def set_branch
      @current_branch = @current_shop.branches.find(params[:id])
    end

    def phone_order_params
      params.require(:phone_order).permit(:name, :phone, :address, :note, :delivery_time, :state, :pay_type, :order_type, :desk_no, :guest_num, :arrive_time, :validation_code, :pay_type, :delivery_zone_id, :delivery_period, :user_id ,form_contents_attributes: [:id, :form_element_id, :label, :content])
    end
end
